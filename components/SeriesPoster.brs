sub init()
    m.focusBorder = m.top.findNode("focusBorder")
    m.poster = m.top.findNode("poster")
    m.title = m.top.findNode("title")
end sub

sub showContent()
    item = m.top.itemContent
    if item = invalid then return

    m.title.text = item.title
    if item.hdPosterUrl <> invalid and item.hdPosterUrl <> ""
        m.poster.uri = item.hdPosterUrl
    else
        m.poster.uri = "pkg:/images/channel-poster.png"
    end if
end sub

sub showFocus()
    if m.top.itemHasFocus
        m.focusBorder.opacity = 1.0
        m.top.scale = [1.04, 1.04]
    else
        m.focusBorder.opacity = 0.0
        m.top.scale = [1.0, 1.0]
    end if
end sub
