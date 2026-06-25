# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FlowSmith is an AI workflow visual orchestration platform. Users compose workflows from LLM nodes and tool nodes via a ReactFlow drag-and-drop editor, which are executed by one of two engines (DAG or LangGraph4j). The backend is Spring Boot 3.4.1 / Java 21; the frontend is React 18 / TypeScript / Vite.

## Build & Development Commands

### Backend (run from `backend/`)
```bash
./mvnw spring-boot:run              # Start on port 8084
./mvnw clean package                # Build JAR
./mvnw test                         # All tests
./mvnw test -Dtest=ClassName        # Single test class
./mvnw test -Dtest=ClassName#method # Single test method
```

### Frontend (run from `frontend/`)
```bash
npm install
npm run dev          # Vite dev server on port 5173, proxies /api → localhost:8084
npm run build        # TypeScript check + Vite build
npm run lint         # ESLint
```

### Database
```bash
mysql -u root -p flowsmith < backend/src/main/resources/schema.sql
```

## Environment Setup

**Backend**: Copy `backend/.env.example` → `backend/.env`. Required vars: `MYSQL_PASSWORD`, `JWT_SECRET` (32+ chars). The app loads `.env` via `spring.config.import` in `application.yml`. If `JWT_SECRET` is empty, a temporary key is auto-generated at startup.

**Frontend**: Copy `frontend/.env.example` → `frontend/.env.local`. Default proxies `/api` to `localhost:8084` (configured in `vite.config.ts`).

**Default login**: `admin` / `admin123` (configurable via `APP_AUTH_DEFAULT_USERNAME` / `APP_AUTH_DEFAULT_PASSWORD` env vars).

**API docs**: Swagger UI at `http://localhost:8084/swagger-ui.html`

## Architecture

### Dual-Engine System

The core architectural pattern is a dual-engine workflow execution system:

- **`EngineSelector`** (`engine/EngineSelector.java`) routes to the correct engine based on `Workflow.engineType` field (`"dag"` or `"langgraph"`, defaulting to `"dag"`).
- **`WorkflowExecutor`** (`engine/WorkflowExecutor.java`) is the interface both engines implement. Key methods: `execute()`, `executeWithCallback()`, `getEngineType()`.
- **DAG engine** (`engine/dag/DAGParser.java`): Kahn's algorithm for topological sort, DFS for cycle detection. Executes nodes sequentially, passing output of node N as input to node N+1.
- **LangGraph4j engine** (`engine/langgraph/`): Builds a `StateGraph` with conditional routing. `NodeAdapter` wraps existing `NodeExecutor` implementations as `AsyncNodeAction` — no rewrite needed.

### Node Executor Pattern

All node types implement `NodeExecutor` interface:
```java
Map<String, Object> execute(WorkflowNode node, Map<String, Object> input);
String getSupportedNodeType();
```

`NodeExecutorFactory` auto-discovers all `NodeExecutor` beans at startup and maps them by `getSupportedNodeType()`.

**For LLM nodes**: Extend `AbstractLLMNodeExecutor` (not `NodeExecutor` directly). This base class handles config extraction, prompt template processing, ChatClient creation, streaming, function calling, and output building. Subclasses only need to implement `getNodeType()`. See `OpenAINodeExecutor`, `DeepSeekNodeExecutor`, `QwenNodeExecutor` etc. for examples.

**Key LLM plumbing**:
- `ChatClientFactory` creates Spring AI `ChatClient` instances dynamically per node config (apiUrl, apiKey, model).
- `PromptTemplateService` handles `{{variable}}` template substitution with two param types: `input` (static value) and `reference` (upstream node output).
- LLM nodes support a `configId` field that references `LLMGlobalConfig` — shared API credentials managed via the settings UI.

### Skills System

Skills are declarative prompt-engineering definitions stored in `backend/src/main/resources/skills/`. Each skill is a directory with a `SKILL.md` (YAML frontmatter + Markdown) and optional `reference/` subdirectory.

`SkillRegistry` scans classpath at startup, caches in `ConcurrentHashMap`. Three-level progressive loading: summary (name+description) → detail (full SKILL.md) → reference docs. Skills are injected into LLM node system prompts and can also be exposed as Spring AI `FunctionCallback` for LLM-initiated invocation.

### Frontend Architecture

- **State**: Zustand stores — `authStore` (JWT token, user info), `workflowStore` (nodes, edges, selected node), `llmConfigStore`.
- **API layer**: `utils/request.ts` creates an Axios instance with JWT interceptor (auto-attaches `Bearer` token) and 401 auto-refresh. All API modules in `api/` use this instance.
- **Flow editor**: `FlowCanvas.tsx` uses `@xyflow/react` (ReactFlow). Node types must match backend `NodeExecutor.getSupportedNodeType()` values.
- **Routing**: `react-router-dom` — `/login`, `/` (main workflow list), `/editor/:id`, `/knowledge`, `/mcp-tools`.

### Database

MySQL 8.0+ with MyBatis-Plus. Key tables: `workflow` (stores `flow_data` as JSON), `node_definition` (pre-seeded with input/output/openai/deepseek/qwen/step/tts/condition types), `execution_record` (stores `node_results` as JSON), `llm_global_config`, `knowledge_base`/`knowledge_chunk`, `agent_memory`, `mcp_tool_config`. Logical deletion via `deleted` field (MyBatis-Plus global config).

## Key Conventions

- **Java style**: Alibaba Java coding guidelines. Comments in Chinese. Use Lombok (`@Data`, `@Slf4j`, `@TableName`). Type suffixes: DTO (transfer), VO (view), DO (entity), Query (filter).
- **Layered architecture**: Controller → Service → Mapper. Controllers must not access DB directly. Service interfaces live in `service/`, implementations in `service/impl/`.
- **Sensitive config**: Always via environment variables (`.env` files, never hardcoded). Backend `.env` is gitignored.
- **Frontend proxy**: Vite dev server proxies `/api` to backend. The `API_BASE_URL` in `config/api.ts` defaults to `/api` (relative). If backend port changes, update `VITE_API_PROXY_TARGET` in `frontend/.env.local`.
- **SSE**: Real-time execution progress uses Server-Sent Events via `Consumer<ExecutionEvent>` callbacks.
