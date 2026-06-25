# FlowSmith

企业级 AI 工作流可视化编排平台，通过拖拽式界面快速构建、编排和执行 AI 工作流，支持 DAG 引擎与 LangGraph4j 双引擎切换，集成 Spring AI 统一接入 OpenAI、DeepSeek、通义千问等主流大模型。

## 技术栈

### 后端
- **框架**: Spring Boot 3.4.1 (Java 21)
- **数据库**: MySQL 8.0 + MyBatis-Plus 3.5.5
- **AI 框架**: Spring AI 1.0.0-M5 + Spring AI Alibaba 1.0.0-M6.1
- **状态图引擎**: LangGraph4j 1.8.0-beta3
- **JSON**: FastJSON2
- **对象存储**: MinIO (可选)

### 前端
- **框架**: React 18 + TypeScript 5
- **流程编辑器**: ReactFlow
- **UI**: Ant Design + Tailwind CSS
- **状态管理**: Zustand
- **构建工具**: Vite 5

## 核心功能

### 可视化流程编辑器
- 基于 ReactFlow 的拖拽式流程图编辑器
- 节点面板、连线配置、参数编辑
- 支持输入/输出/LLM/工具等节点类型

### 双引擎工作流
- **DAG 引擎**: 拓扑排序（Kahn 算法）+ 循环检测（DFS），适用于线性流程
- **LangGraph4j 引擎**: 状态图编排，支持条件分支与动态路由
- EngineSelector 按 `engineType` 字段自动路由，向后兼容

### 多模型统一接入
- **OpenAI 节点**: GPT 系列（Spring AI OpenAI 接口）
- **DeepSeek 节点**: 国产大模型（OpenAI 兼容接口）
- **通义千问节点**: 阿里云千问系列（DashScope 原生支持）
- **智谱 AI 节点**: GLM 系列（OpenAI 兼容接口）
- **AIPing 节点**: 第三方模型代理（OpenAI 兼容接口）

### 工具节点
- **TTS 音频合成**: 通义 Qwen3 TTS、阶跃星辰 StepAudio 超拟人语音
- **输入/输出节点**: 灵活的数据输入输出
- **自定义扩展**: 基于统一接口开发专属节点

### Skills 技能系统
- YAML Frontmatter + Markdown 声明式技能定义
- 三级渐进式加载（摘要 → 详情 → 引用文档）
- Spring AI FunctionCallback 集成，LLM 可自主调用技能

### 实时调试
- SSE 流式输出，实时查看 AI 生成过程
- 内置调试面板，可视化执行过程和日志

## 快速开始

### 环境要求
- Java 21+
- Maven 3.8+
- Node.js 18+
- MySQL 8.0+

### 配置数据库
```bash
mysql -u root -p -e "CREATE DATABASE flowsmith DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p flowsmith < backend/src/main/resources/schema.sql
```

### 配置后端
```bash
cd backend
cp .env.example .env
# 编辑 .env 文件，填写数据库密码、JWT 密钥等配置
```

### 启动后端
```bash
cd backend
./mvnw spring-boot:run
```

### 启动前端
```bash
cd frontend
cp .env.example .env.local
npm install
npm run dev
```

访问 http://localhost:5173

默认账号：`admin` / `admin123`（可在 `backend/.env` 中修改）

## 项目结构

```
├── backend/                              # Spring Boot 后端
│   ├── src/main/java/com/flowsmith/
│   │   ├── engine/                       # 工作流引擎（核心）
│   │   │   ├── WorkflowEngine.java       # 工作流编排引擎
│   │   │   ├── EngineSelector.java       # 双引擎路由选择器
│   │   │   ├── dag/DAGParser.java        # 拓扑排序+循环检测
│   │   │   ├── langgraph/               # LangGraph4j 引擎
│   │   │   ├── skill/                   # Skills 技能系统
│   │   │   ├── llm/                     # LLM 调用层（Spring AI）
│   │   │   └── executor/                # 节点执行器
│   │   ├── controller/                  # REST API
│   │   ├── service/                     # 业务逻辑
│   │   ├── mapper/                      # MyBatis-Plus 数据访问
│   │   ├── entity/                      # 数据库实体
│   │   └── config/                      # 配置类
│   └── pom.xml
├── frontend/                             # React 前端
│   ├── src/
│   │   ├── components/                  # 核心组件
│   │   │   ├── FlowCanvas.tsx           # ReactFlow 流程编辑器
│   │   │   ├── NodePanel.tsx            # 节点面板
│   │   │   ├── DebugDrawer.tsx          # 调试面板
│   │   │   └── SkillSelector.tsx        # 技能选择器
│   │   ├── pages/                       # 页面组件
│   │   ├── store/                       # Zustand 状态管理
│   │   └── api/                         # API 调用层
│   └── package.json
└── docs/                                 # 项目文档
```

## API 端点

### 认证
- `POST /api/auth/login` - 登录

### 工作流管理
- `GET /api/workflows` - 获取工作流列表
- `POST /api/workflows` - 创建工作流
- `PUT /api/workflows/{id}` - 更新工作流
- `DELETE /api/workflows/{id}` - 删除工作流
- `POST /api/workflows/{id}/execute` - 执行工作流

### 执行记录
- `GET /api/executions` - 获取执行记录
- `GET /api/executions/{id}` - 获取执行详情

### 技能管理
- `GET /api/skills` - 获取所有技能列表
- `GET /api/skills/{name}` - 获取指定技能详情
- `GET /api/skills/{name}/references/{ref}` - 获取技能引用文档

### 流式输出
- `GET /api/workflows/{id}/stream` - SSE 流式执行

## 许可证

MIT License
