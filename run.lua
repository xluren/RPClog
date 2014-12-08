local read_file=require("source")
local sink=require("sink")

local tb_key={"key1","key2"}
local tb={}
local queue_tb={}
local interval=10
local regex_str="(%d+) (%w+)"
local log_file="./demo/hello"
local sleep_interval=1
local sink_option = "hello world"

function mk_table(...)
    
    for i=1, arg.n 
    do
        key=tb_key[i]
        tb[key]=arg[i]
    end 
    table.insert(queue_tb,tb)
end 

function produce(co_consumer)
    while true do
        _,status,line=coroutine.resume(read_file.read_line,log_file)
        if status ~=0 
        then 
            os.execute("sleep " .. sleep_interval)
        else
            mk_table(string.match(line, regex_str ))
        end 
        coroutine.resume(co_consumer)
    end
end

function consume()
    local sum=0
    local tmp_time=os.time()
    local processing_time=tmp_time-tmp_time%interval

    deal_tb=sink.deal_tb(sink_option)

    while true do
        if not next(queue_tb) then
            nowtime=os.time()
            if nowtime-processing_time>=interval
            then 
                deal_tb("",1)
                processing_time=processing_time+interval
            end 
            coroutine.yield()
        else
            tb=queue_tb[1]
            nowtime=os.time()
            if nowtime-processing_time>=interval
            then 
                deal_tb(tb,1)
                processing_time=processing_time+interval
            else 
                deal_tb(tb,0)
            end 
            table.remove(queue_tb, 1)
        end 
    end
end

local co_consumer = coroutine.create(consume)
local co_producer = coroutine.create(produce)

coroutine.resume(co_producer, co_consumer)
