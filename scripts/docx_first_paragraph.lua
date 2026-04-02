-- Aplica um estilo customizado ao primeiro parágrafo após cada título.
--
-- Objetivo: imitar o comportamento do PDF (LaTeX), onde o primeiro parágrafo
-- após um heading NÃO é indentado.
--
-- No DOCX, isso é feito envolvendo o parágrafo em um Div com
-- {custom-style="First Paragraph"} e definindo esse estilo no reference.docx.

local function wrap_para_with_style(para, style_name)
  return pandoc.Div({ para }, pandoc.Attr("", {}, { ["custom-style"] = style_name }))
end

function Pandoc(doc)
  local out = {}
  local i = 1
  while i <= #doc.blocks do
    local b = doc.blocks[i]
    table.insert(out, b)

    if b.t == "Header" and i < #doc.blocks then
      local nextb = doc.blocks[i + 1]
      if nextb.t == "Para" then
        table.insert(out, wrap_para_with_style(nextb, "First Paragraph"))
        i = i + 2
      else
        i = i + 1
      end
    else
      i = i + 1
    end
  end
  doc.blocks = out
  return doc
end
