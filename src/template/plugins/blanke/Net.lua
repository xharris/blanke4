Net = {
    obj_update_rate = 0, -- m/s
    
    is_init = false,
    client = nil,
    
    onReceive = nil,    
    onConnect = nil,    
    onDisconnect = nil, 
    
    address = "localhost",
    port = 12345,

    _objects = {},          -- objects sync from other clients _objects = {'client12' = {object1, object2, ...}}
    _local_objects = {},    -- objects added by this client

    id = nil,
    _timer = 0,

    init = function(address, port)
        Net.address = ifndef(address, "localhost") 
        Net.port = ifndef(port, Net.port)     
        Net.is_init = true

        Net._timer = Timer():every(Net.updateObjects, 2):start()

        Debug.log("networking initialized")
        return Net
    end,
    
    update = function(dt,override)
        override = ifndef(override, true)

        if Net.is_init then
            if Net.server then Net.server:update(dt) end
            if Net.client then 
                Net.client:update(dt)
                local data = Net.client:receive()
                if data then
                    Net._onReceive(data)
                end
            end
        end
        return Net
    end,
    
    -- returns "Client" object
    join = function(address, port) 
        if Net.client then return end
        if not Net.is_init then
            Net.init(address, port)
        end
        Net.client = grease.udpClient()
        
        Net.client.callbacks.recv = Net._onReceive

        Net.client.handshake = "blanke_net"
        
        Net.client:setPing()
        Net.client:connect(Net.address, Net.port)
        Net.is_connected = true
        Debug.log("joining")

        return Net
    end,

    disconnect = function()
        if Net.client then Net.client:disconnect() end
        Net.is_init = false
        Net.is_connected = false
        Net.client = nil

        for clientid, objects in pairs(Net._objects) do
            for o, object in ipairs(objects) do
                if not object.keep_on_disconnect then
                    obj:destroy()
                end
            end
        end

        return Net
    end,

    _onReady = function()
        if Net.onReady then Net.onReady() end

        Net.send({
            type="netevent",
            event="object.sync",
            info={
                new_client=clientid
            }
        })
    end,
    
    _onConnect = function(clientid) 
        Debug.log('+ '..clientid)
    end,
    
    _onDisconnect = function(clientid) 
        Debug.log('- '..clientid)
        if Net.onDisconnect then Net.onDisconnect(clientid) end
        
        -- remove that client's object
        for o, object in ipairs(Net._objects[clientid]) do
            if not object.keep_on_disconnect then
                obj:destroy()
            end
        end
        Net._objects[clientid] = nil
    end,
    
    _onReceive = function(data, id)
        local raw_data = data
        if data:starts('{') then
            data = json.decode(data)

        elseif data:starts('"') then
            data = data:sub(2,-2)
        end
        if type(data) == "string" and data:ends('\n') then
            data = data:gsub('\n','')
        end

        if type(data) == "string" and data:ends('-') then
            Net._onDisconnect(data:sub(1,-2))
            return
        end

        if type(data) == "string" and data:ends('+') then
            Net._onConnect(data:sub(1,-2))
            return
        end

        if data.type and data.type == 'netevent' then
            --Debug.log(data.event)

            -- get assigned client id
            if data.event == 'getID' then
                Net.id = data.info
                Net._onReady()
            end

            if data.event == 'client.connect' then
                Net._onConnect(data.info)
            end

            if data.event == 'client.disconnect' then
                Net._onDisconnect(data.info)
            end
            
            -- new object added from diff client
            if data.event == 'object.add' and data.info.clientid ~= Net.id then
                local obj = data.info.object

                Debug.log("added "..obj.classname)
                Net._objects[data.info.clientid] = ifndef(Net._objects[data.info.clientid], {})
                if not Net._objects[data.info.clientid][obj.net_uuid] then
                    Net._objects[data.info.clientid][obj.net_uuid] = _G[obj.classname]()
                    Net._objects[data.info.clientid][obj.net_uuid].net_object = true
                end
            end

            -- update net entity
            if data.event == 'object.update' and data.info.clientid ~= Net.id then
                if Net._objects[data.info.clientid] then
                    local obj = Net._objects[data.info.clientid][data.info.net_uuid]
                    if obj then
                        for var, val in pairs(data.info.values) do
                            obj[var] = val
                        end
                    end
                end
            end

            -- send net object data to other clients
            if data.event == 'object.sync' and data.info.new_client ~= Net.id then
                Net.sendSyncObjects()
            end

            -- send to all clients
            if data.event == 'broadcast' then
                print('ALL:',data.info)
            end
        end

        if Net.onReceive then Net.onReceive(data) end
    end,

    send = function(in_data) 
        data = json.encode(in_data)
        if Net.client then Net.client:send(data) end
        return Net
    end,

    addObject = function(obj)
        if obj.net_object then return end

        obj.net_uuid = uuid()
        --notify the other server clients
        Net.send({
            type='netevent',
            event='object.add',
            info={
                clientid = Net.id,
                object = {net_uuid=obj.net_uuid, classname=obj.classname}
            }
        })
        table.insert(Net._local_objects, obj)
        if obj.netSync then
            obj:netSync()
        end
        return Net
    end,

    sendSyncObjects = function()
        for o, obj in ipairs(Net._local_objects) do
            Net.send({
                type='netevent',
                event='object.add',
                info={
                    clientid = Net.id,
                    object = {net_uuid=obj.net_uuid, classname=obj.classname}
                }
            })
            obj:netSync()
        end
    end,

    updateObjects = function()
        for o, obj in ipairs(Net._local_objects) do
            obj:netSync()
        end
    end,

    draw = function(classname)
        for clientid, objects in pairs(Net._objects) do
            for o, obj in pairs(objects) do
                if classname then
                    if obj.classname == classname then
                        obj:draw()
                    end
                else
                    obj:draw()
                end
            end
        end
        return Net
    end,
    
    --[[
    room_list = function() end,
    room_create
    room_join
    room_leave
    room_clients -- list clients in rooms
    
    entity_add -- add uuid to entity
    entity_remove
    entity_update -- manual update, usage example?

    send -- data
    
    -- events
    trigger
    receive -- data
    client_enter
    client_leave
    ]]
}

return Net