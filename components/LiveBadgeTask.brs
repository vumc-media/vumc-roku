sub init()
    m.top.functionName = "fetchLiveBadge"
end sub

sub fetchLiveBadge()
    transfer = CreateObject("roUrlTransfer")
    transfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    transfer.InitClientCertificates()
    transfer.SetUrl("https://vumc-roku-status.versaillesumcworshipteam.workers.dev/status")
    transfer.EnableEncodings(true)
    body = transfer.GetToString()
    if body = invalid or body = "" then
        m.top.result = {known:false}
        return
    end if
    data = ParseJson(body)
    if data = invalid or data.live = invalid then
        m.top.result = {known:false}
        return
    end if
    traditional = false
    contemporary = false
    if data.live.traditional <> invalid then traditional = data.live.traditional.live = true
    if data.live.contemporary <> invalid then contemporary = data.live.contemporary.live = true
    m.top.result = {known:true, live:(traditional or contemporary)}
end sub
