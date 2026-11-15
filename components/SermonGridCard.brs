sub init()
    m.poster = m.top.findNode("poster")
    m.title = m.top.findNode("title")
    m.focusBorder = m.top.findNode("focusBorder")
end sub

sub showContent()
    item = m.top.itemContent
    if item = invalid then return
    m.title.text = item.title
    m.poster.uri = item.hdPosterUrl
end sub

sub showFocus()
    if m.top.itemHasFocus
        m.focusBorder.opacity = 0.28
    else
        m.focusBorder.opacity = 0.0
    end if
end sub
