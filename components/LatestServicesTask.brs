sub init()
    m.top.functionName = "fetchLatestServices"
end sub

sub fetchLatestServices()
    result = {status:"error", traditional:invalid, contemporary:invalid}
    transfer = CreateObject("roUrlTransfer")
    transfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    transfer.InitClientCertificates()
    transfer.SetUrl("https://vumc-roku-status.versaillesumcworshipteam.workers.dev/latest")
    transfer.EnableEncodings(true)
    body = transfer.GetToString()
    if body <> invalid and body <> ""
        data = ParseJson(body)
        if data <> invalid and data.latestServices <> invalid
            result = data.latestServices
        end if
    end if
    m.top.result = result
end sub
