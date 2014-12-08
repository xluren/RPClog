local sink={}

sink.deal_tb=function(sink_option)
    local sum=0
    return function(tb,timeout)
        if timeout==1
        then 
            print(sum)
            sum=0
        else
            sum=sum+tb.key1
        end 
    end 
end 
return sink
