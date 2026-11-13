sub init()
    m.top.functionName = "resolveDeepLink"
end sub

sub resolveDeepLink()
    requestedId = m.top.contentId
    if requestedId = invalid or requestedId = "" then return

    transfer = CreateObject("roUrlTransfer")
    transfer.SetUrl("https://vumc-video-catalog.versaillesumcworshipteam.workers.dev/videos.xml")
    transfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    transfer.InitClientCertificates()
    body = transfer.GetToString()
    if body = invalid or body = "" then return

    rss = CreateObject("roXMLElement")
    if not rss.Parse(body) then return
    channels = rss.GetNamedElements("channel")
    if channels.Count() = 0 then return

    for each entry in channels[0].GetNamedElements("item")
        ids = entry.GetNamedElements("guid")
        if ids.Count() = 0 then continue for
        guid = ids[0].GetText()
        if guid <> requestedId then continue for

        media = entry.GetNamedElements("media:content")
        if media.Count() = 0 then continue for
        attributes = media[0].GetAttributes()
        if attributes = invalid or attributes.url = invalid or attributes.url = "" then continue for

        item = CreateObject("roSGNode", "ContentNode")
        item.id = guid
        titles = entry.GetNamedElements("title")
        if titles.Count() > 0 then item.title = titles[0].GetText()
        item.url = attributes.url
        item.streamFormat = "mp4"
        thumbnails = entry.GetNamedElements("media:thumbnail")
        if thumbnails.Count() > 0
            poster = thumbnails[0].GetAttributes()
            if poster <> invalid and poster.url <> invalid then item.hdPosterUrl = poster.url
        end if
        m.top.result = item
        return
    end for
end sub
