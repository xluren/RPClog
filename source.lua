require("lfs")

local read_file={}

local tail_file=coroutine.create(function(file_name)

    local file_ino=lfs.attributes(file_name).ino
    local file_handle=io.open(file_name,"r")

    while 1
    do 
        line=file_handle:read("*line")
        if not line 
        then 
            new_file_ino=lfs.attributes(file_name).ino
            if new_file_ino ~= file_ino 
            then 
                file_handle:close()
                file_handle=io.open(file_name,"r")
            else 
                os.execute("sleep 1")
            end 
            coroutine.yield(1,"error")
        else
            coroutine.yield(0,line)
        end 
    end 
    file_handle:close()

end) 
local get_line=coroutine.create(function(file_name)
    while 1
    do
        _,status,line=coroutine.resume(tail_file,file_name)
        coroutine.yield(status,line)
    end
end) 
read_file.read_line=get_line
return  read_file
