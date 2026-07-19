------------------------- [[ EDITE AQUI ]] -----------------------

local CONFIG = {
  BLESS_COMMAND = '!bless', -- comando p comprar a bless
  BLESS_PRICE = 5, -- golds
  BLESS_MONEY = 'ja possui bless', -- mensagem (ou parte dela) simplificada sem acentos
  BLESS_NOTMONEY = 'nao tem dinheiro suficiente', -- mensagem (ou parte dela) simplificada sem acentos
  UPDATE_GOLD = true, -- se estiver true, vai ficar atualizando a quantidade de gold
  ID_GOLD = 3043, -- id do gold
  ID_DOLLAR = 3035,  -- id do dolar
  TEXT_GOLD = 'Using one of ([0-9]+) gold bars...', -- texto de qndo vc usa o gold, não altere o () e o que está dentro
  NPC_NAME = '[NPC] Yama'
}

-- NÃO EDITE NADA ABAIXO DISSO.

--------------------[[ BY RYAN & VICTOR NEOX ]]--------------------
storage.widgetPos = storage.widgetPos or {}

local widgetConfig = [[
UIWidget
  background-color: black
  opacity: 0.8
  padding: 0 5
  focusable: true
  phantom: false
  draggable: true
  text-auto-resize: true
]]

local blessWidget = {}

blessWidget['goldWidget'] = setupUI(widgetConfig, g_ui.getRootWidget());
blessWidget['blessWidget'] = setupUI(widgetConfig, g_ui.getRootWidget());

local function attachSpellWidgetCallbacks(key)
  blessWidget[key].onDragEnter = function(widget, mousePos)
      if not modules.corelib.g_keyboard.isCtrlPressed() then
          return false
      end
      widget:breakAnchors()
      widget.movingReference = { x = mousePos.x - widget:getX(), y = mousePos.y - widget:getY() }
      return true
  end

  blessWidget[key].onDragMove = function(widget, mousePos, moved)
      local parentRect = widget:getParent():getRect()
      local x = math.min(math.max(parentRect.x, mousePos.x - widget.movingReference.x), parentRect.x + parentRect.width - widget:getWidth())
      local y = math.min(math.max(parentRect.y - widget:getParent():getMarginTop(), mousePos.y - widget.movingReference.y), parentRect.y + parentRect.height - widget:getHeight())
      widget:move(x, y)
      return true
  end

  blessWidget[key].onDragLeave = function(widget, pos)
      storage.widgetPos[key] = {}
      storage.widgetPos[key].x = widget:getX();
      storage.widgetPos[key].y = widget:getY();
      return true
  end
end

for key, value in pairs(blessWidget) do
  attachSpellWidgetCallbacks(key)
  blessWidget[key]:setPosition(
      storage.widgetPos[key] or {0, 50}
  )
end

-------------------------------------------------------------------

----------------------------[[ SCRIPT ]]---------------------------

-- Função auxiliar para remover acentos e facilitar a checagem de texto do OT
local function cleanText(str)
    if not str then return "" end
    str = str:lower()
    str = str:gsub("[ãâàáä]", "a")
    str = str:gsub("[ẽêèéë]", "e")
    str = str:gsub("[ĩîìíï]", "i")
    str = str:gsub("[õôòóö]", "o")
    str = str:gsub("[ũûùúü]", "u")
    str = str:gsub("ç", "c")
    return str
end

local goldCount = 0;
onTextMessage(function(mode, text)
  if text:find(CONFIG.TEXT_GOLD) then
      goldCount = tonumber(text:match("%d+"))
      blessWidget['goldWidget']:setText('Golds: ' .. goldCount)
  end
end);

if storage.haveBless == nil then storage.haveBless = false end

local blessScript = macro(1000, "Bless", function() -- Aumentado o intervalo para 1 segundo para evitar spam
  if not storage.haveBless then
      say(CONFIG.BLESS_COMMAND)
      blessWidget['blessWidget']:setText("Bless: None | Bless Restante: " .. math.floor(goldCount / CONFIG.BLESS_PRICE))
      blessWidget['blessWidget']:setColor("red")
  else
      blessWidget['blessWidget']:setText("Bless: True | Bless Restante: " .. math.floor(goldCount / CONFIG.BLESS_PRICE))
      blessWidget['blessWidget']:setColor("green")
      local findNpc = getCreatureByName(CONFIG.NPC_NAME);
      if findNpc and getDistanceBetween(pos(), findNpc:getPosition()) <= 4 then
         NPC.say('hi')
      end
  end
end)

macro(1, function()
  if blessScript.isOff() then return; end
  if CONFIG.UPDATE_GOLD then
      if findItem(CONFIG.ID_GOLD) and (not X or X <= os.time()) then
          use(CONFIG.ID_GOLD)
          delay(400)
          use(CONFIG.ID_DOLLAR)
          X = os.time() + 180
      end
  end
end);

onTextMessage(function(mode, text)
  if blessScript.isOff() then return; end
  
  local cleanedMessage = cleanText(text)
  local configMoney = cleanText(CONFIG.BLESS_MONEY)
  local configNoMoney = cleanText(CONFIG.BLESS_NOTMONEY)
  
  if cleanedMessage:find(configNoMoney) then
      storage.haveBless = false
  elseif cleanedMessage:find(configMoney) then
      storage.haveBless = true
  end
end);
