sub init()
    m.top.functionName = "loadPodcast"
end sub

function podcastTagText(parent as Object, name as String) as String
    nodes = parent.GetNamedElements(name)
    if nodes <> invalid and nodes.Count() > 0 then return nodes[0].GetText()
    return ""
end function

sub loadPodcast()
    root = CreateObject("roSGNode", "ContentNode")
    transfer = CreateObject("roUrlTransfer")
    transfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    transfer.AddHeader("User-Agent", "VersaillesUMC-Roku/1.95")
    transfer.SetUrl("https://anchor.fm/s/102cd8e28/podcast/rss")
    feed = transfer.GetToString()
    if feed = invalid or feed = "" then
        m.top.episodes = root
        return
    end if

    doc = CreateObject("roXMLElement")
    if not doc.Parse(feed) then
        m.top.episodes = root
        return
    end if
    channels = doc.GetNamedElements("channel")
    if channels = invalid or channels.Count() = 0 then
        m.top.episodes = root
        return
    end if
    channel = channels[0]
    showArtwork = "pkg:/images/logo.png"
    for each ch in channel.GetChildElements()
        tag = LCase(ch.GetName())
        if tag = "image" or tag = "itunes:image"
            attrs = ch.GetAttributes()
            if attrs <> invalid and attrs["href"] <> invalid and attrs["href"] <> "" then
                showArtwork = attrs["href"]
            else
                url = podcastTagText(ch, "url")
                if url <> "" then showArtwork = url
            end if
        end if
    end for
    items = channel.GetNamedElements("item")
    if items <> invalid
        for each episode in items
            audioUrl = ""
            audioType = ""
            artwork = showArtwork
            for each node in episode.GetChildElements()
                tag = LCase(node.GetName())
                attrs = node.GetAttributes()
                if tag = "enclosure" and attrs <> invalid
                    if attrs["url"] <> invalid then audioUrl = attrs["url"]
                    if attrs["type"] <> invalid then audioType = LCase(attrs["type"])
                else if attrs <> invalid and (tag = "itunes:image" or tag = "image" or tag = "media:thumbnail" or tag = "thumbnail")
                    if attrs["href"] <> invalid and attrs["href"] <> "" then artwork = attrs["href"]
                    if attrs["url"] <> invalid and attrs["url"] <> "" then artwork = attrs["url"]
                end if
            end for
            ' RSS audio enclosures only; Spotify video is not distributed in this feed.
            if audioUrl <> "" and (Instr(1, audioType, "audio/") = 1 or audioType = "")
                item = root.CreateChild("ContentNode")
                item.title = podcastTagText(episode, "title")
                item.id = podcastTagText(episode, "guid")
                if item.id = "" then item.id = audioUrl
                item.url = audioUrl
                item.streamFormat = "mp3"
                item.hdPosterUrl = artwork
                item.shortDescriptionLine1 = podcastTagText(episode, "pubDate")
            end if
        end for
    end if
    m.top.episodes = root
end sub
