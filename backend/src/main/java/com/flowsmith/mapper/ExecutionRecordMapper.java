package com.flowsmith.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.flowsmith.entity.ExecutionRecord;
import org.apache.ibatis.annotations.Mapper;

/**
 * 执行记录 Mapper 接口
 */
@Mapper
public interface ExecutionRecordMapper extends BaseMapper<ExecutionRecord> {
}
