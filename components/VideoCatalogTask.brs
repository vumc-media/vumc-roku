' Archive.org sermon series catalog, beta only.
' Builds ContentNode: Sermons -> Series -> Episodes.
sub init()
    m.top.functionName = "loadArchiveCatalog"
end sub

function fetchArchiveJson(url as String) as Dynamic
    req = CreateObject("roUrlTransfer")
    req.SetCertificatesFile("common:/certs/ca-bundle.crt")
    req.InitClientCertificates()
    req.SetUrl(url)
    req.EnableEncodings(true)
    body = req.GetToString()
    if body = invalid or body = "" then return invalid
    return ParseJson(body)
end function

function archiveTags(value as Dynamic) as Object
    result = []
    if value = invalid then return result
    if type(value) = "roArray"
        for each v in value
            for each part in v.Tokenize(";")
                result.Push(LCase(Trim(part)))
            end for
        end for
    else
        for each part in value.Tokenize(";")
            result.Push(LCase(Trim(part)))
        end for
    end if
    return result
end function

function getSeriesName(value as Dynamic) as String
    if value = invalid then return ""
    if type(value) = "roArray"
        for each tag in value
            for each part in tag.Tokenize(";")
                part = Trim(part)
                if Left(LCase(part), 7) = "series:" then return Trim(Mid(part, 8))
            end for
        end for
    else
        for each part in value.Tokenize(";")
            part = Trim(part)
            if Left(LCase(part), 7) = "series:" then return Trim(Mid(part, 8))
        end for
    end if
    return ""
end function

function hasTag(tags as Object, wanted as String) as Boolean
    for each tag in tags
        if tag = wanted then return true
    end for
    return false
end function

sub loadArchiveCatalog()
    root = CreateObject("roSGNode", "ContentNode")
    section = CreateObject("roSGNode", "ContentNode")
    section.title = "Sermons"
    section.hdPosterUrl = "pkg:/images/logo.png"
    section.addField("cardColor", "string", false)
    section.cardColor = "0x304C68FF"
    root.appendChild(section)

    searchUrl = "https://archive.org/advancedsearch.php?q=uploader%3A%22versaillesumcworshipteam%40gmail.com%22%20AND%20mediatype%3Amovies&fl%5B%5D=identifier&fl%5B%5D=title&fl%5B%5D=publicdate&sort%5B%5D=publicdate%20desc&rows=1000&output=json"
    search = fetchArchiveJson(searchUrl)
    if search = invalid or search.response = invalid or search.response.docs = invalid
        m.top.videos = invalid
        return
    end if

    seriesNodes = {}
    for each doc in search.response.docs
        identifier = doc.identifier
        if identifier = invalid or identifier = "" then continue for
        metaUrl = "https://archive.org/metadata/" + identifier
        data = fetchArchiveJson(metaUrl)
        if data = invalid or data.metadata = invalid or data.files = invalid then continue for
        metadata = data.metadata
        tags = archiveTags(metadata.subject)
        if not hasTag(tags, "type:sermon") then continue for
        seriesName = getSeriesName(metadata.subject)
        if seriesName = "" then continue for

        filename = ""
        duration = 0
        for each f in data.files
            if f.source = "original" and Right(LCase(f.name), 4) = ".mp4"
                filename = f.name
                if f.length <> invalid then duration = Val(f.length)
                exit for
            end if
        end for
        if filename = ""
            for each f in data.files
                if Right(LCase(f.name), 4) = ".mp4"
                    filename = f.name
                    if f.length <> invalid then duration = Val(f.length)
                    exit for
                end if
            end for
        end if
        if filename = "" then continue for

        transfer = CreateObject("roUrlTransfer")
        videoUrl = "https://archive.org/download/" + identifier + "/" + transfer.Escape(filename)
        posterUrl = "https://archive.org/download/" + identifier + "/__ia_thumb.jpg"
        episode = CreateObject("roSGNode", "ContentNode")
        episode.id = identifier
        if metadata.title <> invalid then
            episode.title = metadata.title
        else
            episode.title = identifier
        end if
        episode.url = videoUrl
        episode.streamFormat = "mp4"
        episode.hdPosterUrl = posterUrl
        episode.addField("cardColor", "string", false)
        episode.cardColor = "0x263F56FF"

        key = LCase(seriesName)
        if not seriesNodes.DoesExist(key)
            series = CreateObject("roSGNode", "ContentNode")
            series.title = seriesName
            series.hdPosterUrl = posterUrl
            series.addField("cardColor", "string", false)
            series.cardColor = "0x365575FF"
            section.appendChild(series)
            seriesNodes[key] = series
        end if
        seriesNodes[key].appendChild(episode)
    end for

    if section.getChildCount() = 0
        m.top.videos = invalid
    else
        m.top.videos = root
    end if
end sub
