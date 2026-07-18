-- ==========================================
-- CONFIGURA  ES DE EVAS O MULTI-ID
-- ==========================================
-- Adicione aqui dentro todos os IDs de efeitos suspeitos
local IDs_Perigo = {347, 348, 349} 

-- Fun  o auxiliar para checar se um ID est  na lista de perigo
local function verificarPerigo(id)
    for _, perigoId in ipairs(IDs_Perigo) do
        if id == perigoId then
            return true
        end
    end
    return false
end

macro(50, "Esquiva de area (Boss) Multi-ID", function()
    local minhaPos = pos()
    
    local tileAtual = g_map.getTile(minhaPos)
    if not tileAtual or not tileAtual.getEffects then return end
    
    local temPerigo = false
    for _, eff in ipairs(tileAtual:getEffects()) do
        if verificarPerigo(eff:getId()) then
            temPerigo = true
            break
        end
    end
    
    -- 2. Se o boneco estiver em cima do perigo, calcula um SQM seguro
    if temPerigo then
        -- Lista de 8 dire  es: Retos + Diagonais
        local direcoes = {
            {dir = North,     x = 0,  y = -1},
            {dir = East,      x = 1,  y = 0},
            {dir = South,     x = 0,  y = 1},
            {dir = West,      x = -1, y = 0},
            {dir = NorthEast, x = 1,  y = -1},
            {dir = SouthEast, x = 1,  y = 1},
            {dir = SouthWest, x = -1, y = 1},
            {dir = NorthWest, x = -1, y = -1}
        }
        
        for _, d in ipairs(direcoes) do
            local posChecagem = {x = minhaPos.x + d.x, y = minhaPos.y + d.y, z = minhaPos.z}
            local tileAlvo = g_map.getTile(posChecagem)
            
            if tileAlvo and tileAlvo:isWalkable() then
                local sqmSeguro = true
                
                for _, eff in ipairs(tileAlvo:getEffects() or {}) do
                    if verificarPerigo(eff:getId()) then
                        sqmSeguro = false
                        break
                    end
                end
                
                if sqmSeguro then
                    g_game.walk(d.dir)
                    info("[Esquiva] Movendo para SQM seguro (Dire  o: " .. tostring(d.dir) .. ")!")
                    delay(220) 
                    return
                end
            end
        end
    end
end)
