sub init()
    m.top.functionName = "checkLiveStreams"
end sub

sub checkLiveStreams()
    transfer = CreateObject("roUrlTransfer")
    transfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    transfer.InitClientCertificates()
    transfer.SetUrl("https://vumc-roku-status.versaillesumcworshipteam.workers.dev/status")
    transfer.EnableEncodings(true)
    body = transfer.GetToString()
    if body = invalid or body = ""
        m.top.result = {live:false, error:"Status service unavailable"}
        return
    end if
    data = ParseJson(body)
    if data = invalid or data.live = invalid
        m.top.result = {live:false, error:"Invalid status response"}
        return
    end if
    choices = []
    if data.live.traditional <> invalid and data.live.traditional.live = true
        choices.Push({title:"Traditional Worship", url:data.live.traditional.hls})
    end if
    if data.live.contemporary <> invalid and data.live.contemporary.live = true
        choices.Push({title:"Contemporary Worship", url:data.live.contemporary.hls})
    end if
    nextTitle = ""
    nextTime = ""
    nextStartsAt = ""
    if data.calendar <> invalid and data.calendar.nextService <> invalid
        nextTitle = data.calendar.nextService.name
        nextTime = data.calendar.nextService.displayTime
        nextStartsAt = data.calendar.nextService.startsAt
    end if
    m.top.result = {live:choices.Count()>0, choices:choices, nextTitle:nextTitle, nextTime:nextTime, nextStartsAt:nextStartsAt}
end sub
