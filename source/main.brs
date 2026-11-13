sub Main(args as Dynamic)
    screen = CreateObject("roSGScreen")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    scene = screen.CreateScene("HomeScene")

    input = CreateObject("roInput")
    input.SetMessagePort(port)

    if args <> invalid and args.contentid <> invalid and args.contentid <> ""
        scene.deepLink = {
            contentId: args.contentid
            mediaType: args.mediatype
        }
    end if

    scene.ObserveField("exitRequested", port)
    screen.Show()

    while true
        msg = wait(0, port)
        if type(msg) = "roSGScreenEvent" and msg.isScreenClosed()
            return
        else if type(msg) = "roSGNodeEvent"
            if msg.GetField() = "exitRequested" and msg.GetData() = true
                screen.Close()
                return
            end if
        else if type(msg) = "roInputEvent"
            info = msg.GetInfo()
            if info <> invalid and info.contentid <> invalid and info.contentid <> ""
                scene.deepLink = info
            end if
        end if
    end while
end sub
