function onCreated()
  pages = script:triggerFunction("getPages", "Scripts/Pages.lua")

  viewButton = pages[1].elements.openButton
  listBox = pages[1].elements.listBox
  listBox:setSelected(1)
  script:triggerFunction("onButtonPressed", "Scripts/Pages.lua", viewButton)
  topPage = script:triggerFunction("getTopModal", "Scripts/Pages.lua")

  topPage.elements.title:setText("THIS IS A TEST FROM SCRIPT testTest.lua")
end