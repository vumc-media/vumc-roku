sub init()
    m.focusBg = m.top.findNode("focusBg")
    m.accent = m.top.findNode("accent")
    m.art = m.top.findNode("art")
    m.title = m.top.findNode("title")
    m.date = m.top.findNode("date")
end sub

sub showContent()
    item = m.top.itemContent
    if item = invalid then return
    m.title.text = item.title
    m.date.text = item.shortDescriptionLine1
    if item.hdPosterUrl <> invalid and item.hdPosterUrl <> ""
        m.art.uri = item.hdPosterUrl
    else
        m.art.uri = "pkg:/images/logo.png"
    end if
end sub

sub showFocus()
    if m.top.itemHasFocus
        m.focusBg.opacity = 1.0
        m.accent.opacity = 1.0
    else
        m.focusBg.opacity = 0.0
        m.accent.opacity = 0.0
    end if
end sub
