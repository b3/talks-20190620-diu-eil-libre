pandoc.List = require 'pandoc.List'
function Header (header)
   if header.level > 2 then
      if not header.classes:includes("block", 1) then
         local inlines = pandoc.List:new{}
         inlines:extend {pandoc.RawInline('tex', '\\structure{')}
         inlines:extend(header.content)
         inlines:extend {pandoc.RawInline('tex', '}')}
         return pandoc.Plain(inlines)
      end
   end
end
