sub init()
 m.background=m.top.findNode("background")
 m.poster=m.top.findNode("poster")
 m.shade=m.top.findNode("shade")
 m.title=m.top.findNode("title")
 m.titleBackdrop=m.top.findNode("titleBackdrop")
 m.recentBg=m.top.findNode("recentBg")
 m.recentText=m.top.findNode("recentText")
 m.focusOutline=m.top.findNode("focusOutline")
 m.liveBadgeBg=m.top.findNode("liveBadgeBg")
 m.liveBadge=m.top.findNode("liveBadge")
end sub
sub showContent()
 item=m.top.itemContent
 if item=invalid then return
 displayTitle = item.title
 if item.hasField("cardDisplayTitle") and item.cardDisplayTitle <> invalid and item.cardDisplayTitle <> "" then displayTitle = item.cardDisplayTitle
 m.title.text=displayTitle
 m.liveBadgeBg.visible=false
 m.liveBadge.visible=false
 if item.hasField("liveBadge")
  item.observeField("liveBadge","onLiveBadgeChanged")
  onLiveBadgeChanged()
 end if
 m.recentBg.visible=false
 m.recentText.visible=false
 if item.hasField("recentlyAdded")
  if item.recentlyAdded=true
   m.recentBg.visible=true
   m.recentText.visible=true
  end if
 end if
 if item.cardColor<>invalid and item.cardColor<>"" then m.background.color=item.cardColor
 hasPoster=item.hdPosterUrl<>invalid and item.hdPosterUrl<>""
 m.poster.visible=hasPoster
 if hasPoster then m.poster.uri=item.hdPosterUrl
end sub
sub showFocusPercent()
 amount=m.top.focusPercent
 if amount=invalid then amount=0.0
 m.shade.opacity=1.0-(amount*0.65)
 m.focusOutline.opacity=amount
end sub
sub showFocus()
 if m.top.itemHasFocus
  m.shade.opacity=0.35
  m.focusOutline.opacity=1.0
 else
  m.shade.opacity=1.0
  m.focusOutline.opacity=0.0
 end if
end sub
sub onLiveBadgeChanged()
 item=m.top.itemContent
 if item=invalid then return
 active=false
 if item.hasField("liveBadge") then active=item.liveBadge=true
 m.liveBadgeBg.visible=active
 m.liveBadge.visible=active
end sub
