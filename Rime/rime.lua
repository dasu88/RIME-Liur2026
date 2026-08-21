-- rime.lua
-- 嘸蝦米輸入法 Lua 模組載入

-- 符號資料表（數字變體、字母變體）
local symbol_data = require("liu_symbol_data")
local number_symbols = symbol_data.number_symbols
local letter_symbols = symbol_data.letter_symbols

-- date_translator: 符號表變體處理（`a 字母變體，`'01 數字變體）
function date_translator(input, seg)
  -- 擴充模式（``）由 liu_letter_variants.lua 和 liu_datetime.lua 處理
  if seg:has_tag("extended_mode") then
    return
  end
  
  -- 數字變體模式（`'）
  if seg:has_tag("number_variant") then
    -- 空輸入：顯示等待提示
    if input == "" then
      yield(Candidate("number_variant_hint", seg.start, seg._end, "請輸入數字 (00~50)", ""))
      return
    end
    
    -- 只有1位數字：顯示等待提示
    local single_digit = string.match(input, "^(%d)$")
    if single_digit then
      local cand = Candidate("number_variant_hint", seg.start, seg._end, "請輸入第二位數字 (00~50)", "")
      cand.preedit = "《變體數字》" .. single_digit
      yield(cand)
      return
    end
    
    -- 數字變體：`'01 到 `'50（必須兩位數字）
    local num = string.match(input, "^(%d%d)$")
    if num then
      local num_key = tostring(tonumber(num))  -- 去掉前導零：01 → 1
      if number_symbols[num_key] then
        local preedit = "《變體" .. num_key .. "》" .. num
        for _, symbol in ipairs(number_symbols[num_key]) do
          local cand = Candidate("number_variant", seg.start, seg._end, symbol, "")
          cand.preedit = preedit
          yield(cand)
        end
      end
    end
    return
  end
  
  -- 符號表模式（`）- 處理字母變體（Ⓐ）
  if seg:has_tag("symbols") then
    local letter = string.match(input, "^([a-z])$")
    if letter and letter_symbols[letter] then
      local preedit = "《變體" .. letter .. "》" .. letter
      for _, symbol in ipairs(letter_symbols[letter]) do
        local cand = Candidate("letter_variant", seg.start, seg._end, symbol, "")
        cand.preedit = preedit
        yield(cand)
      end
    end
    return
  end
end

-- liu_phonetic_suffix: 嘸蝦米同音字模式（選中後按 '）
local liu_phonetic_suffix = require("liu_phonetic_suffix")
liu_phonetic_suffix_processor = liu_phonetic_suffix.processor
liu_phonetic_suffix_translator = liu_phonetic_suffix.translator
liu_phonetic_suffix_filter = liu_phonetic_suffix.filter

-- 各功能模組載入

-- 符號表相關
local liu_symbols_hint_module = require("liu_symbols_hint")
liu_symbols_hint = liu_symbols_hint_module.translator
liu_symbols_hint_filter = require("liu_symbols_hint_filter")
liu_symbols_processor = require("liu_symbols_processor")
liu_symbols_number_processor = require("liu_symbols_number_processor")

-- 擴充模式（``）相關
liu_extended_backspace = require("liu_extended_backspace")
liu_extended_segmentor = require("liu_extended_segmentor")
liu_letter_variants = require("liu_letter_variants")
liu_datetime = require("liu_datetime")
liu_extended_filter = require("liu_extended_filter")