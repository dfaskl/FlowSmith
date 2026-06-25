package com.flowsmith.engine.executor;

import com.flowsmith.dto.ExecutionEvent;
import com.flowsmith.engine.model.WorkflowNode;

import java.util.Map;
import java.util.function.Consumer;

public interface NodeExecutor {
    
    Map<String, Object> execute(WorkflowNode node, Map<String, Object> input) throws Exception;
    
    default Map<String, Object> execute(WorkflowNode node, Map<String, Object> input, Consumer<ExecutionEvent> progressCallback) throws Exception {
        return execute(node, input);
    }
    
    String getSupportedNodeType();
}