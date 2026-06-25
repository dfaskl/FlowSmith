package com.flowsmith.engine.agent;

import com.flowsmith.engine.model.WorkflowNode;

import java.util.Map;

/**
 * Execution context exposed to ReAct runtime tools.
 */
public record AgentToolContext(
        WorkflowNode node,
        Map<String, Object> currentInput
) {
}
