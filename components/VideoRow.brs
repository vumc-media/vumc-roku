sub init()
    m.focusBg = m.top.findNode("focusBg")
    m.accent = m.top.findNode("accent")
    m.thumb = m.top.findNode("thumb")
    m.title = m.top.findNode("title")
    m.series = m.top.findNode("series")
end sub

sub showContent()
    item = m.top.itemContent
    if item = invalid then return
    m.title.text = item.title
    m.series.text = item.shortDescriptionLine1
    if item.hdPosterUrl <> invalid and item.hdPosterUrl <> ""
        m.thumb.uri = item.hdPosterUrl
        m.thumb.loadDisplayMode = "scaleToZoom"
    else
        m.thumb.uri = "pkg:/images/icon_play.png"
        m.thumb.loadDisplayMode = "scaleToFit"
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
