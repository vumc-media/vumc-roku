sub init()
    m.sideMenu = m.top.findNode("sideMenu")
    m.menuSelectionBg = m.top.findNode("menuSelectionBg")
    m.menuHint = m.top.findNode("menuHint")
    m.menuSlideIn = m.top.findNode("menuSlideIn")
    m.menuSlideOut = m.top.findNode("menuSlideOut")
    m.menuOpen = false
    m.menuIndex = 0
    m.homeSubpage = false
    m.clock = m.top.findNode("topBarClock")
    m.aboutScreen = m.top.findNode("aboutScreen")
    m.videoLibraryScreen = m.top.findNode("videoLibraryScreen")
    m.seriesGrid = m.top.findNode("seriesGrid")
    m.sermonSeriesScreen = m.top.findNode("sermonSeriesScreen")
    m.sermonSeriesGrid = m.top.findNode("sermonSeriesGrid")
    m.browseTitle = m.top.findNode("browseTitle")
    m.browseSubtitle = m.top.findNode("browseSubtitle")
    m.seriesVideosScreen = m.top.findNode("seriesVideosScreen")
    m.seriesTitle = m.top.findNode("seriesTitle")
    m.videoList = m.top.findNode("videoList")
    m.connectScreen = m.top.findNode("connectScreen")
    m.connectGrid = m.top.findNode("connectGrid")
    m.connectHeading = m.top.findNode("connectHeading")
    m.connectSubtitle = m.top.findNode("connectSubtitle")
    m.connectDetailScreen = m.top.findNode("connectDetailScreen")
    m.connectDetailPoster = m.top.findNode("connectDetailPoster")
    m.videoStatus = m.top.findNode("videoStatus")
    m.libraryPlayerScreen = m.top.findNode("livePlayerScreen")
    m.libraryVideo = m.top.findNode("liveVideo")
    m.livePlayerScreen = m.top.findNode("livePlayerScreen")
    m.liveVideo = m.top.findNode("liveVideo")
    m.liveOverlay = m.top.findNode("liveOverlay")
    m.recordingLoadingOverlay = m.top.findNode("recordingLoadingOverlay")
    m.liveWallpaper = m.top.findNode("liveWallpaper")
    m.liveStatus = m.top.findNode("liveStatus")
    m.liveService = m.top.findNode("liveService")
    m.liveSpinner = m.top.findNode("liveSpinner")
    m.nextWorshipPanel = m.top.findNode("nextWorshipPanel")
    m.nextWorshipName = m.top.findNode("nextWorshipName")
    m.nextWorshipTime = m.top.findNode("nextWorshipTime")
    m.nextDays = m.top.findNode("nextDays")
    m.nextHours = m.top.findNode("nextHours")
    m.nextMinutes = m.top.findNode("nextMinutes")
    m.nextSeconds = m.top.findNode("nextSeconds")
    m.podcastScreen = m.top.findNode("podcastScreen")
    m.podcastList = m.top.findNode("podcastList")
    m.podcastStatus = m.top.findNode("podcastStatus")
    m.podcastArtwork = m.top.findNode("podcastArtwork")
    m.podcastNowTitle = m.top.findNode("podcastNowTitle")
    m.podcastPlayerOverlay = m.top.findNode("podcastPlayerOverlay")
    m.podcastProgress = m.top.findNode("podcastProgress")
    m.podcastElapsed = m.top.findNode("podcastElapsed")
    m.podcastDuration = m.top.findNode("podcastDuration")
    m.podcastPlayState = m.top.findNode("podcastPlayState")
    m.homeRows = m.top.findNode("homeRows")
    m.homeStatus = m.top.findNode("homeStatus")
    m.homeHeroImage = m.top.findNode("homeHeroImage")
    m.homeHeroTitle = m.top.findNode("homeHeroTitle")
    m.homeHeroSubtitle = m.top.findNode("homeHeroSubtitle")
    m.homeHeroDescription = m.top.findNode("homeHeroDescription")
    m.heroFade = m.top.findNode("heroFade")

    ' Give adaptive HLS a short period to ramp up after the 5:10 seek.
    m.recordingQualityTimer = CreateObject("roSGNode", "Timer")
    m.recordingQualityTimer.duration = 7
    m.recordingQualityTimer.repeat = false
    m.recordingQualityTimer.observeField("fire", "onRecordingQualityTimer")
    m.top.appendChild(m.recordingQualityTimer)
    m.recordingQualityWaitStarted = false

    m.liveVideo.observeField("state", "onUniversalVideoStateChanged")
    m.liveVideo.observeField("position", "onRecordedVideoPosition")
    m.homeRows.observeField("rowItemSelected", "onHomeItemSelected")
    m.homeRows.observeField("rowItemFocused", "onHomeItemFocused")
    m.latestServices = invalid
    m.isLiveNow = false
    m.liveBadgeTask = invalid
    m.liveBadgeTimer = CreateObject("roSGNode", "Timer")
    m.liveBadgeTimer.duration = 60
    m.liveBadgeTimer.repeat = true
    m.liveBadgeTimer.observeField("fire", "refreshLiveBadge")
    m.top.appendChild(m.liveBadgeTimer)

    m.browseStack = []
    m.mode = "home"
    m.top.setFocus(true)

    m.timer = CreateObject("roSGNode", "Timer")
    m.timer.duration = 30
    m.timer.repeat = true
    m.timer.observeField("fire", "updateClock")
    m.top.appendChild(m.timer)
    m.timer.control = "start"

    m.countdownTimer = CreateObject("roSGNode", "Timer")
    m.countdownTimer.duration = 1
    m.countdownTimer.repeat = true
    m.countdownTimer.observeField("fire", "updateCountdown")
    m.top.appendChild(m.countdownTimer)
    m.nextStartsAt = ""
    m.nextTitle = ""
    m.nextTime = ""
    m.offAirSeconds = 0

    m.bookmarkTimer = CreateObject("roSGNode", "Timer")
    m.bookmarkTimer.duration = 10
    m.bookmarkTimer.repeat = true
    m.bookmarkTimer.observeField("fire", "saveCurrentBookmark")
    m.top.appendChild(m.bookmarkTimer)

    updateClock()
    finishStartup()
end sub

sub finishStartup()
    loadHomeCatalog()
    refreshLiveBadge()
    m.liveBadgeTimer.control = "start"
    m.top.signalBeacon("AppLaunchComplete")

end sub

sub onDeepLink()
    request = m.top.deepLink
    if request = invalid then return
    requestedId = request.contentId
    if requestedId = invalid or requestedId = "" then requestedId = request.contentid
    if requestedId = invalid or requestedId = "" then return

    mediaType = request.mediaType
    if mediaType = invalid or mediaType = "" then mediaType = request.mediatype
    if mediaType <> invalid and mediaType <> "" and LCase(mediaType) <> "episode" and LCase(mediaType) <> "movie" then return

    m.pendingContentId = requestedId
    if m.deepLinkTask <> invalid then m.deepLinkTask.control = "stop"
    m.deepLinkTask = CreateObject("roSGNode", "DeepLinkCatalogTask")
    m.deepLinkTask.contentId = requestedId
    m.deepLinkTask.observeField("result", "onDeepLinkResolved")
    m.deepLinkTask.control = "RUN"
end sub

sub onDeepLinkResolved()
    if m.deepLinkTask = invalid then return
    item = m.deepLinkTask.result
    if item = invalid then
        print "Deep link not found or catalog unavailable: "; m.pendingContentId
        return
    end if
    if m.pendingContentId <> item.id then return
    m.pendingContentId = ""
    m.videoLibraryScreen.visible = false
    m.sermonSeriesScreen.visible = false
    m.seriesVideosScreen.visible = false
    playVideoItem(item, "home")
end sub

sub updateClock()
    dt = CreateObject("roDateTime")
    dt.ToLocalTime()
    h = dt.GetHours()
    min = dt.GetMinutes()
    suffix = "AM"
    if h >= 12 then suffix = "PM"
    if h = 0 then h = 12
    if h > 12 then h = h - 12
    mins = min.ToStr()
    if min < 10 then mins = "0" + mins
    m.clock.text = h.ToStr() + ":" + mins + " " + suffix
end sub

sub loadHomeCatalog()
    ' v98: Home is built locally; no R2 video catalog fetch.
    m.skipFirstHomeHeroUpdate = true
    m.homeRows.content = buildHomeRows(invalid, false)
    m.homeStatus.text = ""
    loadLatestServices()
    if m.mode = "home"
        showHomeIntro()
        m.homeRows.jumpToRowItem = [0, 0]
        m.homeRows.setFocus(true)
        showHomeIntro()
    end if
end sub

function buildHomeRows(catalog as Object, includeLatest as Boolean) as Object
    root = CreateObject("roSGNode", "ContentNode")

    liveRow = root.CreateChild("ContentNode")
    liveRow.title = "WATCH LIVE"
    universalLive = addHomeItem(liveRow, "Watch Live", "", "live", "", "pkg:/images/live-worship-photo-dark.jpg", "0x176C7AFF")
    universalLive.heroUrl = "pkg:/images/live-worship-photo-dark.jpg"
    universalLive.AddFields({liveBadge: m.isLiveNow})

    if includeLatest
    latestRow = root.CreateChild("ContentNode")
    latestRow.title = "LATEST STREAMS"

    ' Roku v66: Cloudflare Stream is the primary source for Latest Services.
    ' Show two service cards even when Stream is temporarily unavailable.
    if m.latestServices <> invalid and m.latestServices.status = "connected"
        addCloudflareLatest(latestRow, m.latestServices.traditional, "Traditional Worship", "pkg:/images/gradients/red.png")
        addCloudflareLatest(latestRow, m.latestServices.contemporary, "Contemporary Worship", "pkg:/images/gradients/teal.png")
    else
        addLatestUnavailable(latestRow, "Traditional Worship", "pkg:/images/gradients/red.png")
        addLatestUnavailable(latestRow, "Contemporary Worship", "pkg:/images/gradients/teal.png")
    end if

    end if

    ' v133: Home shows Watch Live only; Latest Streams loads from its sidebar destination.
    return root
end function


' Update the Watch Live tile without interrupting the current Roku selection.
sub refreshLiveBadge()
    if m.liveBadgeTask <> invalid then return
    m.liveBadgeTask = CreateObject("roSGNode", "LiveBadgeTask")
    m.liveBadgeTask.observeField("result", "onLiveBadgeResult")
    m.liveBadgeTask.control = "RUN"
end sub

sub onLiveBadgeResult()
    if m.liveBadgeTask = invalid then return
    result = m.liveBadgeTask.result
    m.liveBadgeTask = invalid
    if result = invalid then return
    ' Unknown/network failure: keep previous state until next poll.
    if result.known <> true then return
    m.isLiveNow = result.live = true
    if m.homeRows.content = invalid then return
    root = m.homeRows.content
    if root.getChildCount() = 0 then return
    row = root.getChild(0)
    if row = invalid or row.getChildCount() = 0 then return
    item = row.getChild(0)
    if item <> invalid and item.hasField("liveBadge")
        item.liveBadge = m.isLiveNow
    end if
end sub

sub loadLatestServices()
    m.latestTask = CreateObject("roSGNode", "LatestServicesTask")
    m.latestTask.observeField("result", "onLatestServicesLoaded")
    m.latestTask.control = "RUN"
end sub

sub onLatestServicesLoaded()
    if m.latestTask = invalid then return
    response = m.latestTask.result
    if response = invalid then return
    m.latestServices = response
    ' Refresh only the Latest row; do not reset selection or interrupt playback.
    if m.homeRows.content = invalid then return
    root = m.homeRows.content
    if root.getChildCount() < 2 then return
    row = root.getChild(1)
    row.removeChildrenIndex(row.getChildCount(), 0)
    if response.status = "connected"
        addCloudflareLatest(row, response.traditional, "Traditional Worship", "pkg:/images/gradients/red.png")
        addCloudflareLatest(row, response.contemporary, "Contemporary Worship", "pkg:/images/gradients/teal.png")
    else
        addLatestUnavailable(row, "Traditional Worship", "pkg:/images/gradients/red.png")
        addLatestUnavailable(row, "Contemporary Worship", "pkg:/images/gradients/teal.png")
    end if
    selection = m.homeRows.rowItemFocused
    if selection <> invalid and selection.Count() >= 2
        if selection[0] = 1 and selection[1] >= 0 and selection[1] < row.getChildCount()
            updateFeaturedHeader(row.getChild(selection[1]))
        end if
    end if
end sub

sub addCloudflareLatest(parent as Object, video as Dynamic, title as String, poster as String)
    if video = invalid then
        addLatestUnavailable(parent, title, poster)
        return
    end if
    videoUrl = video.hls
    if videoUrl = invalid or videoUrl = "" then videoUrl = video.url
    if videoUrl = invalid or videoUrl = "" then
        addLatestUnavailable(parent, title, poster)
        return
    end if
    item = addHomeItem(parent, title, "", "video", "", poster, "0x165C85FF")
    item.id = video.uid
    item.url = videoUrl
    item.streamFormat = "hls"
    ' Use a still from 10:00 in the actual Cloudflare recording.
    ' Keep the existing gradient if a playback URL cannot provide a thumbnail.
    if videoUrl.Instr("/manifest/") >= 0
        thumbBase = videoUrl.Split("/manifest/")[0]
        item.hdPosterUrl = thumbBase + "/thumbnails/thumbnail.jpg?time=600s&height=600&fit=crop"
    else if video.thumbnail <> invalid and video.thumbnail <> ""
        item.hdPosterUrl = video.thumbnail
    end if
    ' v108: Use the new Cloudflare Worker v66.1 display metadata.
    displayDate = ""
    if video.worshipDateDisplay <> invalid then displayDate = video.worshipDateDisplay
    sermonTitle = ""
    if video.sermonTitle <> invalid then sermonTitle = video.sermonTitle
    sermonDescription = ""
    if video.sermonDescription <> invalid then sermonDescription = video.sermonDescription
    if displayDate <> "" then item.shortDescriptionLine1 = displayDate
    cardTitle = title
    if title = "Traditional Worship" then cardTitle = "Traditional"
    if title = "Contemporary Worship" then cardTitle = "Contemporary"
    item.AddFields({recentlyAdded: true, cardDisplayTitle: cardTitle, worshipDisplayDate: displayDate, sermonDisplayTitle: sermonTitle, sermonDisplayDescription: sermonDescription})
end sub

sub addLatestUnavailable(parent as Object, title as String, poster as String)
    item = addHomeItem(parent, title, "", "unavailable", "", poster, "0x165C85FF")
    cardTitle = title
    if title = "Traditional Worship" then cardTitle = "Traditional"
    if title = "Contemporary Worship" then cardTitle = "Contemporary"
    item.AddFields({cardDisplayTitle: cardTitle})
end sub

sub addLatestService(parent as Object, source as Object, title as String)
    item = addHomeItem(parent, title, "", "video", "", "pkg:/images/gradients/teal.png", "0x165C85FF")
    item.id = source.id
    item.url = source.url
    item.streamFormat = source.streamFormat
end sub

function addHomeItem(parent as Object, title as String, subtitle as String, action as String, target as String, posterUrl as String, cardColor as String) as Object
    item = parent.CreateChild("ContentNode")
    item.title = title
    item.shortDescriptionLine1 = subtitle
    item.hdPosterUrl = posterUrl
    item.sdPosterUrl = posterUrl
    item.AddFields({
        homeAction: action,
        homeTarget: target,
        cardColor: cardColor,
        heroUrl: posterUrl
    })
    return item
end function

function findFirstPoster(node as Object) as String
    if node = invalid then return ""

    if node.hdPosterUrl <> invalid and node.hdPosterUrl <> ""
        return node.hdPosterUrl
    end if

    for i = 0 to node.getChildCount() - 1
        posterUrl = findFirstPoster(node.getChild(i))
        if posterUrl <> "" then return posterUrl
    end for

    return ""
end function

sub onHomeItemFocused()
    if m.mode <> "home" then return
    selection = m.homeRows.rowItemFocused
    if selection = invalid or selection.Count() < 2 then return
    if selection[0] < 0 or selection[1] < 0 then return
    catalog = m.homeRows.content
    if catalog = invalid then return
    row = catalog.getChild(selection[0])
    if row = invalid then return
    item = row.getChild(selection[1])
    if item = invalid then return
    if selection[0] = 0 and selection[1] = 0 then return
    updateFeaturedHeader(item)
end sub

sub updateFeaturedHeader(item as Object)
    if item = invalid then return
    title = item.title
    subtitle = ""
    description = ""
    art = "pkg:/images/worship-header.jpg"
    if item.hasField("heroUrl") and item.heroUrl <> invalid and item.heroUrl <> ""
        art = item.heroUrl
    end if
    if item.hasField("homeAction") and item.homeAction = "video"
        if item.hdPosterUrl <> invalid and item.hdPosterUrl <> "" then art = item.hdPosterUrl
        if item.hasField("sermonDisplayTitle") and item.sermonDisplayTitle <> ""
            title = item.sermonDisplayTitle
        end if
        subtitle = item.title
        if item.hasField("worshipDisplayDate") and item.worshipDisplayDate <> ""
            subtitle = subtitle + "  |  " + item.worshipDisplayDate
        end if
        if item.hasField("sermonDisplayDescription") and item.sermonDisplayDescription <> ""
            description = item.sermonDisplayDescription
        else
            description = "Watch the latest " + item.title + " service from Versailles United Methodist Church."
        end if
    else if item.hasField("homeAction")
        action = item.homeAction
        if action = "live"
            title = "WATCH LIVE"
            subtitle = "Traditional 9:30 AM  |  Contemporary 10:30 AM"
            description = "Join us for worship live from Versailles, Kentucky."
        else if action = "podcast"
            title = "SERMON PODCASTS"
            subtitle = "Church Beyond Sunday"
            description = "Listen to messages from Versailles United Methodist Church."
        else if action = "partner"
            title = "CONNECT & PARTNER"
            subtitle = "Love Like Jesus"
            description = "Discover ways to support and participate in our community ministries."
        else if action = "connect"
            title = "CONNECT WITH US"
            subtitle = "Versailles United Methodist Church"
            description = "Stay connected with worship, church news, and upcoming events."
        else if action = "about"
            title = "ABOUT VERSAILLES UMC"
            subtitle = "A Church Striving to Love Like Jesus"
            description = "Learn about our church, our mission, and our worship gatherings."
        else if action = "unavailable"
            subtitle = "Recording temporarily unavailable"
            description = "Please check back soon for the latest worship recording."
        end if
    end if
    m.homeHeroImage.uri = art
    m.homeHeroTitle.text = title
    m.homeHeroSubtitle.text = subtitle
    m.homeHeroDescription.text = description
end sub

sub showHomeIntro()
    m.homeSubpage = false
    m.homeHeroImage.uri = "pkg:/images/worship-header.jpg"
    m.homeHeroTitle.text = "WELCOME TO VERSAILLES UMC"
    m.homeHeroSubtitle.text = "A Church Striving to Love Like Jesus"
    m.homeHeroDescription.text = "Traditional worship at 9:30 AM and contemporary worship at 10:30 AM. Join us in Versailles, Kentucky."
end sub

function findSectionByTitle(catalog as Object, wantedTitle as String) as Object
    if catalog = invalid then return invalid

    for i = 0 to catalog.getChildCount() - 1
        section = catalog.getChild(i)
        if LCase(section.title) = LCase(wantedTitle) then return section
    end for

    return invalid
end function

sub onHomeItemSelected()
    selection = m.homeRows.rowItemSelected
    if selection = invalid or selection.Count() < 2 then return
    if selection[0] < 0 or selection[1] < 0 then return

    row = m.homeRows.content.getChild(selection[0])
    if row = invalid then return
    item = row.getChild(selection[1])
    if item = invalid then return

    action = item.homeAction
    if action = "live"
        openLive(item.homeTarget)
    else if action = "video"
        playVideoItem(item, "home")
    else if action = "unavailable"
        loadLatestServices()
    else if action = "about"
        m.mode = "about"
        m.aboutScreen.visible = true
        m.top.setFocus(true)
    else if action = "podcast"
        openPodcast()
    else if action = "connect"
        openConnect()
    else if action = "partner"
        openPartner()
    end if
end sub

sub openPartner()
    root = CreateObject("roSGNode", "ContentNode")
    addConnectItem(root, "Diaper Bank", "Supplies for local families", "pkg:/images/gradients/red.png", "pkg:/images/connect/diaper-bank.jpg", "0x783A3FFF")
    addConnectItem(root, "Blessing Box", "Food and essentials for neighbors", "pkg:/images/gradients/green.png", "pkg:/images/connect/blessing-box.jpg", "0x34733EFF")
    addConnectItem(root, "Monday Meals", "Community meals and delivery", "pkg:/images/gradients/teal.png", "pkg:/images/connect/third-monday-meal.jpg", "0x8C4A10FF")
    addConnectItem(root, "Backpacks", "Weekend food for children", "pkg:/images/gradients/red.png", "pkg:/images/connect/backpack-buddies.jpg", "0x8A7418FF")
    addConnectItem(root, "Give Online", "Scan to give", "pkg:/images/gradients/green.png", "pkg:/images/gradients/qr-giving.png", "0x34733EFF")
    m.connectHeading.text = "PARTNER WITH US"
    m.connectSubtitle.text = "Love Like Jesus through outreach and giving"
    m.connectGrid.content = root
    m.connectScreen.visible = true
    m.mode = "connect"
    m.connectGrid.jumpToItem = 0
    m.connectGrid.setFocus(true)
end sub

sub openConnect()
    root = CreateObject("roSGNode", "ContentNode")
    addConnectItem(root, "Church Center", "Scan to connect", "pkg:/images/gradients/teal.png", "pkg:/images/gradients/qr-churchcenter.png", "0x1D6670FF")
    addConnectItem(root, "YouTube", "Scan to subscribe", "pkg:/images/gradients/red.png", "pkg:/images/gradients/qr-youtube.png", "0x8C4A10FF")
    m.connectHeading.text = "CONNECT WITH US"
    m.connectSubtitle.text = "Stay connected with worship, church news, and upcoming events."
    m.connectGrid.content = root
    m.connectScreen.visible = true
    m.mode = "connect"
    m.connectGrid.jumpToItem = 0
    m.connectGrid.setFocus(true)
end sub

sub addConnectItem(parent as Object, title as String, subtitle as String, thumbUrl as String, detailUrl as String, cardColor as String)
    item = parent.CreateChild("ContentNode")
    item.title = title
    item.shortDescriptionLine1 = ""
    item.hdPosterUrl = thumbUrl
    item.sdPosterUrl = thumbUrl
    item.AddFields({
        detailPosterUrl: detailUrl,
        cardColor: cardColor
    })
end sub

sub openSelectedConnectItem()
    item = m.connectGrid.content.getChild(m.connectGrid.itemFocused)
    if item = invalid then return
    if item.title = "Stay Connected"
        showStayConnectedChoice()
        return
    end if
    if item.detailPosterUrl = invalid or item.detailPosterUrl = "" then return

    m.connectDetailPoster.uri = item.detailPosterUrl
    m.connectScreen.visible = false
    m.connectDetailScreen.visible = true
    m.mode = "connectDetail"
    m.top.setFocus(true)
end sub

 ' Signup preview: never collect or transmit addresses without an approved endpoint.
sub showStayConnectedChoice()
    d = CreateObject("roSGNode", "Dialog")
    d.title = "Stay Connected with Versailles UMC"
    d.message = "Receive worship news and ministry updates. Signup is optional. This test build demonstrates email entry; no address will be sent or saved."
    d.buttons = ["Enter Email", "Not Now"]
    d.observeField("buttonSelected", "onStayConnectedChoice")
    m.top.dialog = d
end sub

sub onStayConnectedChoice()
    d = m.top.dialog
    if d = invalid then return
    selected = d.buttonSelected
    d.close = true
    if selected = 0
        keyboard = CreateObject("roSGNode", "StandardKeyboardDialog")
        keyboard.title = "Your Email Address"
        keyboard.message = "Enter the address you would use for VUMC updates. This is a preview only."
        keyboard.buttons = ["Continue", "Cancel"]
        keyboard.observeField("buttonSelected", "onStayConnectedEmailEntered")
        m.top.dialog = keyboard
    end if
end sub

sub onStayConnectedEmailEntered()
    d = m.top.dialog
    if d = invalid then return
    selected = d.buttonSelected
    email = d.text
    d.close = true
    if selected <> 0 then return
    if email = invalid then email = ""
    atPos = Instr(1, email, "@")
    dotPos = Instr(atPos + 1, email, ".")
    if atPos <= 1 or dotPos <= atPos + 1 or dotPos >= Len(email)
        result = CreateObject("roSGNode", "Dialog")
        result.title = "Check Email Address"
        result.message = "Please enter a complete email address, including @ and a domain."
        result.buttons = ["OK"]
        m.top.dialog = result
        return
    end if
    result = CreateObject("roSGNode", "Dialog")
    result.title = "Signup Preview"
    result.message = "Email entry works. No email was saved or sent. Church mailing-list integration and email verification must be configured before signups can go live."
    result.buttons = ["OK"]
    m.top.dialog = result
end sub

sub openLive(serviceName as String)
    m.selectedLiveService = "Live Worship"
    m.liveWallpaper.uri = "pkg:/images/live-worship-photo-dark.jpg"
    m.livePlayerScreen.visible = true
    m.liveOverlay.visible = true
    m.nextWorshipPanel.visible = false
    m.liveService.visible = true
    m.liveStatus.visible = true
    m.liveSpinner.visible = true
    m.liveSpinner.control = "start"
    m.liveService.text = "LIVE WORSHIP"
    m.liveStatus.text = "Checking the live worship broadcast..."
    m.mode = "liveConnecting"
    m.countdownTimer.control = "stop"
    m.liveStatusTask = CreateObject("roSGNode", "LiveStatusTask")
    m.liveStatusTask.observeField("result", "onLiveStatusChecked")
    m.liveStatusTask.control = "RUN"
end sub

sub onLiveStatusChecked()
    if m.mode <> "liveConnecting" then return
    result = m.liveStatusTask.result
    if result = invalid or result.live <> true
        m.liveSpinner.control = "stop"
        m.liveSpinner.visible = false
        m.liveService.text = "WORSHIP IS CURRENTLY OFF AIR"
        m.nextWorshipPanel.visible = true
        m.liveService.visible = false
        m.liveStatus.visible = false
        m.mode = "liveOffAir"
        m.offAirSeconds = 0
        m.nextStartsAt = ""
        if result <> invalid
            m.nextTitle = result.nextTitle
            m.nextTime = result.nextTime
            m.nextStartsAt = result.nextStartsAt
        end if
        updateCountdown()
        m.countdownTimer.control = "start"
        return
    end if
    if result.choices.Count() > 1
        m.liveChoices = result.choices
        dialog = CreateObject("roSGNode", "Dialog")
        dialog.title = "Choose a live worship service"
        dialog.buttons = ["Traditional Worship", "Contemporary Worship"]
        dialog.observeField("buttonSelected", "onLiveChoiceSelected")
        m.liveChoiceDialog = dialog
        m.top.dialog = dialog
        m.liveSpinner.control = "stop"
        m.liveSpinner.visible = false
        m.mode = "liveChoosing"
    else
        startLiveChoice(result.choices[0])
    end if
end sub

sub updateCountdown()
    if m.mode <> "liveOffAir" then return
    if m.nextStartsAt = invalid or m.nextStartsAt = ""
        m.nextWorshipName.text = "Worship schedule temporarily unavailable"
        m.nextWorshipTime.text = "Please check back soon"
        m.nextDays.text = "--"
        m.nextHours.text = "--"
        m.nextMinutes.text = "--"
        m.nextSeconds.text = "--"
        m.offAirSeconds = m.offAirSeconds + 1
        if m.offAirSeconds >= 60
            m.offAirSeconds = 0
            checkLiveAgain()
        end if
        return
    end if

    target = CreateObject("roDateTime")
    target.FromISO8601String(m.nextStartsAt)
    now = CreateObject("roDateTime")
    remaining = target.AsSeconds() - now.AsSeconds()
    if remaining <= 0
        m.nextWorshipName.text = "Worship is scheduled to begin"
        m.nextWorshipTime.text = "Checking the live broadcast..."
        m.countdownTimer.control = "stop"
        checkLiveAgain()
        return
    end if

    days = Int(remaining / 86400)
    hours = Int((remaining MOD 86400) / 3600)
    minutes = Int((remaining MOD 3600) / 60)
    seconds = remaining MOD 60
    m.nextWorshipName.text = m.nextTitle
    m.nextWorshipTime.text = m.nextTime
    m.nextDays.text = padCountdown(days)
    m.nextHours.text = padCountdown(hours)
    m.nextMinutes.text = padCountdown(minutes)
    m.nextSeconds.text = padCountdown(seconds)

    m.offAirSeconds = m.offAirSeconds + 1
    if m.offAirSeconds >= 60
        m.offAirSeconds = 0
        checkLiveAgain()
    end if
end sub

function padCountdown(value as Integer) as String
    if value < 10 then return "0" + value.ToStr()
    return value.ToStr()
end function

sub checkLiveAgain()
    if m.mode <> "liveOffAir" then return
    m.countdownTimer.control = "stop"
    m.mode = "liveConnecting"
    m.nextWorshipPanel.visible = false
    m.liveService.visible = true
    m.liveStatus.visible = true
    m.liveStatusTask = CreateObject("roSGNode", "LiveStatusTask")
    m.liveStatusTask.observeField("result", "onLiveStatusChecked")
    m.liveStatusTask.control = "RUN"
end sub

sub onUniversalVideoStateChanged()
    if m.mode = "libraryVideo"
        onLibraryVideoStateChanged()
    else if m.mode = "liveConnecting" or m.mode = "liveVideo"
        onLiveVideoStateChanged()
    end if
end sub

sub onLiveChoiceSelected()
    index = m.liveChoiceDialog.buttonSelected
    m.top.dialog = invalid
    if index >= 0 and index < m.liveChoices.Count()
        startLiveChoice(m.liveChoices[index])
    else
        closeLive()
    end if
end sub

sub startLiveChoice(choice as Object)
    if choice = invalid or choice.url = invalid or choice.url = "" then return
    m.selectedLiveService = choice.title
    m.nextWorshipPanel.visible = false
    m.liveService.visible = true
    m.liveStatus.visible = true
    m.liveService.text = UCase(choice.title)
    m.liveStatus.text = "Connecting to live worship..."
    content = CreateObject("roSGNode", "ContentNode")
    content.title = choice.title
    content.url = choice.url
    content.streamFormat = "hls"
    m.liveVideo.content = content
    m.liveVideo.visible = true
    m.mode = "liveConnecting"
    m.liveVideo.setFocus(true)
    m.liveVideo.control = "play"
end sub

sub onLiveVideoStateChanged()
    state = m.liveVideo.state

    if state = "playing"
        m.liveSpinner.control = "stop"
        m.liveSpinner.visible = false
        m.liveOverlay.visible = false
        m.mode = "liveVideo"
    else if state = "error"
        m.liveVideo.control = "stop"
        m.liveSpinner.control = "stop"
        m.liveSpinner.visible = false
        m.liveOverlay.visible = true
        m.liveService.text = UCase(m.selectedLiveService)
        m.liveStatus.text = "The live service could not be played." + Chr(10) + Chr(10) + "Press BACK and try again."
        m.mode = "liveOffAir"
    else if state = "finished"
        m.liveSpinner.control = "stop"
        m.liveSpinner.visible = false
        m.liveOverlay.visible = true
        m.liveService.text = UCase(m.selectedLiveService)
        m.liveStatus.text = "The live service has ended." + Chr(10) + Chr(10) + "Press BACK to return home."
        m.mode = "liveOffAir"
    end if
end sub

sub closeLive()
    if m.top.dialog <> invalid then m.top.dialog = invalid
    ' Do not wait for a running network task. Its callback is ignored
    ' after mode changes from liveConnecting.
    m.countdownTimer.control = "stop"
    m.liveVideo.control = "stop"
    m.liveSpinner.control = "stop"
    m.liveSpinner.visible = false
    m.liveOverlay.visible = true
    m.livePlayerScreen.visible = false
    m.mode = "home"
    showHomeIntro()
    m.homeRows.setFocus(true)
end sub

sub openVideoLibrary()
    m.pendingSection = ""
    m.libraryEntry = "library"
    loadVideoLibrary()
end sub

sub openLibraryTarget(target as String)
    m.pendingSection = LCase(target)
    m.libraryEntry = "home"
    loadVideoLibrary()
end sub

sub loadVideoLibrary()
    m.mode = "videos"
    m.videoLibraryScreen.visible = true
    m.videoStatus.text = "Loading video library..."
    m.seriesGrid.content = CreateObject("roSGNode", "ContentNode")
    m.sermonSeriesGrid.content = CreateObject("roSGNode", "ContentNode")
    m.videoList.content = CreateObject("roSGNode", "ContentNode")
    m.catalogTask = CreateObject("roSGNode", "VideoCatalogTask")
    m.catalogTask.observeField("videos", "onVideosLoaded")
    m.catalogTask.control = "RUN"
end sub

sub onVideosLoaded()
    if m.catalogTask.videos = invalid
        m.videoStatus.text = "Sermon catalog unavailable. Try again later."
        return
    end if

    m.seriesGrid.content = m.catalogTask.videos

    if m.pendingContentId <> invalid and m.pendingContentId <> ""
        deepLinkItem = findVideoById(m.catalogTask.videos, m.pendingContentId)

        if deepLinkItem <> invalid
            m.pendingContentId = ""
            m.videoLibraryScreen.visible = false
            playVideoItem(deepLinkItem, "home")
            return
        end if

        m.pendingContentId = ""
        m.videoStatus.text = "The requested service is no longer available."
    end if

    if m.catalogTask.videos.getChildCount() = 0
        m.videoStatus.text = "No videos are available yet."
    else
        m.videoStatus.text = "Choose Sermons and press OK"
        m.seriesGrid.jumpToItem = 0
        m.seriesGrid.setFocus(true)

        if m.pendingSection <> invalid and m.pendingSection <> ""
            for i = 0 to m.catalogTask.videos.getChildCount() - 1
                section = m.catalogTask.videos.getChild(i)
                normalizedTitle = LCase(section.title)
                if normalizedTitle = m.pendingSection or Left(normalizedTitle, Len(m.pendingSection)) = m.pendingSection
                    m.seriesGrid.jumpToItem = i
                    m.pendingSection = ""
                    openSectionNode(section)
                    return
                end if
            end for
            m.videoStatus.text = "This section has no videos yet. Press BACK to return home."
        end if
    end if
end sub

sub openVideoCollection(collection as Object, returnMode as String)
    if collection = invalid then return
    m.selectedSeries = collection
    m.returnMode = returnMode
    m.seriesTitle.text = UCase(collection.title)
    m.videoList.content = collection
    m.videoLibraryScreen.visible = false
    m.sermonSeriesScreen.visible = false
    m.seriesVideosScreen.visible = true
    m.mode = "seriesVideos"
    m.videoList.jumpToItem = 0
    m.videoList.setFocus(true)
end sub

sub openSelectedSection()
    section = m.seriesGrid.content.getChild(m.seriesGrid.itemFocused)
    openSectionNode(section)
end sub

sub openSectionNode(section as Object)
    if section = invalid or section.getChildCount() = 0 then return

    firstChild = section.getChild(0)
    if firstChild.url <> invalid and firstChild.url <> ""
        if m.libraryEntry = "home"
            openVideoCollection(section, "home")
        else
            openVideoCollection(section, "videos")
        end if
    else
        m.browseStack = []
        showBrowseNode(section)
    end if
end sub

sub openSelectedSermonSeries()
    selectedNode = m.sermonSeriesGrid.content.getChild(m.sermonSeriesGrid.itemFocused)
    if selectedNode = invalid or selectedNode.getChildCount() = 0 then return

    firstChild = selectedNode.getChild(0)
    if firstChild.url <> invalid and firstChild.url <> ""
        openVideoCollection(selectedNode, "sermonSeries")
    else
        m.browseStack.Push(m.sermonSeriesGrid.content)
        showBrowseNode(selectedNode)
    end if
end sub

sub showBrowseNode(node as Object)
    if node = invalid then return

    m.browseTitle.text = UCase(node.title)
    normalizedTitle = LCase(node.title)

    if normalizedTitle = "current series"
        m.browseSubtitle.text = "Choose a current sermon series"
    else if normalizedTitle = "library"
        m.browseSubtitle.text = "Choose an archived sermon series"
    else
        m.browseSubtitle.text = "Choose a sermon series"
    end if

    m.sermonSeriesGrid.content = node
    m.videoLibraryScreen.visible = false
    m.sermonSeriesScreen.visible = true
    m.mode = "sermonSeries"
    m.sermonSeriesGrid.jumpToItem = 0
    m.sermonSeriesGrid.setFocus(true)
end sub

sub playLibraryVideo()
    item = m.videoList.content.getChild(m.videoList.itemFocused)
    if item = invalid or item.url = invalid or item.url = "" then return

    playVideoItem(item, "seriesVideos")
end sub

sub playVideoItem(item as Object, returnMode as String)
    if item = invalid or item.url = invalid or item.url = "" then return

    content = CreateObject("roSGNode", "ContentNode")
    content.id = item.id
    content.title = item.title
    content.url = item.url
    format = item.streamFormat
    if format = invalid or format = "" then format = "mp4"
    content.streamFormat = format

    m.countdownTimer.control = "stop"
    m.livePlayerScreen.visible = true
    m.podcastPlayerOverlay.visible = (returnMode = "podcast")
    if returnMode = "podcast"
        m.podcastProgress.width = 2
        m.podcastElapsed.text = "0:00"
        m.podcastDuration.text = "--:--"
        m.podcastPlayState.text = "PLAYING"
    end if
    if returnMode = "podcast"
        m.podcastArtwork.uri = item.hdPosterUrl
        m.podcastNowTitle.text = item.title
    end if
    m.liveOverlay.visible = false
    m.recordingLoadingOverlay.visible = false
    ' A starting bitrate is a preference, not a forced quality level.
    ' Guard this optional field for Roku firmware compatibility.
    if returnMode = "home" and format = "hls" and m.libraryVideo.hasField("initialBitrate")
        m.libraryVideo.initialBitrate = 3000000
    end if
    m.libraryVideo.content = content
    m.videoReturnMode = returnMode
    m.currentVideoId = item.id
    m.currentVideoCompleted = false
    m.resumePosition = readBookmark(m.currentVideoId)

    ' Only the two latest home-screen Cloudflare worship recordings skip the countdown.
    m.recordingQualityTimer.control = "stop"
    m.recordingQualityWaitStarted = false
    m.recordingStartPending = false
    m.recordingSeekIssued = false
    m.recordingStartTarget = 0
    if returnMode = "home" and format = "hls" and (item.title = "Traditional Worship" or item.title = "Contemporary Worship")
        m.recordingStartTarget = 310
        ' Respect a viewer's later bookmark rather than sending them backwards.
        if m.resumePosition > m.recordingStartTarget then m.recordingStartTarget = m.resumePosition
        m.resumePosition = 0
        m.recordingStartPending = true
    end if

    ' Keep the countdown frames hidden until the initial seek completes.
    m.libraryVideo.visible = not m.recordingStartPending
    m.nextWorshipPanel.visible = false
    m.liveService.visible = true
    m.liveStatus.visible = true
    m.liveOverlay.visible = false
    m.recordingLoadingOverlay.visible = m.recordingStartPending
    if m.recordingStartPending
        m.liveSpinner.control = "stop"
        m.liveSpinner.visible = false
    end if
    m.mode = "libraryVideo"
    m.libraryVideo.setFocus(true)
    m.libraryVideo.control = "play"
    m.bookmarkTimer.control = "start"
end sub

function podcastTime(seconds as Dynamic) as String
    if seconds = invalid or seconds < 0 then return "--:--"
    whole = Int(seconds)
    hrs = Int(whole / 3600)
    mins = Int((whole MOD 3600) / 60)
    secs = whole MOD 60
    ss = secs.ToStr()
    if secs < 10 then ss = "0" + ss
    if hrs > 0
        mm = mins.ToStr()
        if mins < 10 then mm = "0" + mm
        return hrs.ToStr() + ":" + mm + ":" + ss
    end if
    return mins.ToStr() + ":" + ss
end function

sub updatePodcastProgress()
    if m.videoReturnMode <> "podcast" then return
    duration = m.libraryVideo.duration
    position = m.libraryVideo.position
    m.podcastElapsed.text = podcastTime(position)
    m.podcastDuration.text = podcastTime(duration)
    if duration <> invalid and duration > 0 and position <> invalid
        fraction = position / duration
        if fraction < 0 then fraction = 0
        if fraction > 1 then fraction = 1
        m.podcastProgress.width = Int(1110 * fraction)
    end if
end sub

function findVideoById(node as Object, contentId as String) as Object
    if node = invalid then return invalid

    if node.id <> invalid and node.id = contentId and node.url <> invalid and node.url <> ""
        return node
    end if

    for i = 0 to node.getChildCount() - 1
        match = findVideoById(node.getChild(i), contentId)
        if match <> invalid then return match
    end for

    return invalid
end function

function readBookmark(contentId as String) as Float
    if contentId = invalid or contentId = "" then return 0.0

    section = CreateObject("roRegistrySection", "VUMCBookmarks")
    value = section.Read(contentId)

    if value = invalid or value = "" then return 0.0
    return Val(value)
end function

sub saveCurrentBookmark()
    if m.mode <> "libraryVideo" then return
    if m.currentVideoId = invalid or m.currentVideoId = "" then return
    if m.currentVideoCompleted = true then return

    position = m.libraryVideo.position
    if position = invalid or position < 10 then return

    duration = m.libraryVideo.duration
    if duration <> invalid and duration > 0 and position >= duration - 30
        clearCurrentBookmark()
        return
    end if

    section = CreateObject("roRegistrySection", "VUMCBookmarks")
    section.Write(m.currentVideoId, position.ToStr())
    section.Flush()
end sub

sub clearCurrentBookmark()
    if m.currentVideoId = invalid or m.currentVideoId = "" then return

    section = CreateObject("roRegistrySection", "VUMCBookmarks")
    section.Delete(m.currentVideoId)
    section.Flush()
end sub

sub onLibraryVideoStateChanged()
    state = m.libraryVideo.state
    if m.videoReturnMode = "podcast"
        if state = "paused" then
            m.podcastPlayState.text = "PAUSED"
        else if state = "playing" then
            m.podcastPlayState.text = "PLAYING"
        else if state = "buffering" then
            m.podcastPlayState.text = "BUFFERING"
        else if state = "finished" then
            m.podcastPlayState.text = "FINISHED"
        end if
        updatePodcastProgress()
    end if

    if state = "playing" and m.recordingStartPending
        ' Assign seek once. The position observer reveals the video after it arrives.
        if not m.recordingSeekIssued
            m.recordingSeekIssued = true
            duration = m.libraryVideo.duration
            if duration <> invalid and duration > 0 and duration <= m.recordingStartTarget + 5
                m.recordingStartTarget = 0
            end if
            if m.recordingStartTarget > 0
                m.libraryVideo.seek = m.recordingStartTarget
            else
                revealRecordedVideo()
            end if
        end if
    else if state = "playing" and m.resumePosition <> invalid and m.resumePosition > 10
        resumeAt = m.resumePosition
        m.resumePosition = 0
        m.libraryVideo.seek = resumeAt
    else if state = "finished"
        m.bookmarkTimer.control = "stop"
        m.currentVideoCompleted = true
        clearCurrentBookmark()
    else if state = "error"
        m.recordingQualityTimer.control = "stop"
        if m.recordingStartPending
            m.recordingLoadingOverlay.visible = false
            m.liveOverlay.visible = true
            m.liveService.text = "PLAYBACK UNAVAILABLE"
            m.liveStatus.text = "Unable to load the worship service. Please try again."
            m.liveSpinner.control = "stop"
            m.liveSpinner.visible = false
            m.recordingStartPending = false
        end if
        m.bookmarkTimer.control = "stop"
        saveCurrentBookmark()
    end if
end sub

sub onRecordedVideoPosition()
    if m.mode = "libraryVideo" and m.videoReturnMode = "podcast"
        updatePodcastProgress()
    end if
    if m.mode <> "libraryVideo" or not m.recordingStartPending then return
    if not m.recordingSeekIssued then return
    position = m.libraryVideo.position
    if position = invalid then return
    if position >= m.recordingStartTarget - 3 and not m.recordingQualityWaitStarted
        m.recordingQualityWaitStarted = true
        m.recordingQualityTimer.control = "start"
    end if
end sub

sub onRecordingQualityTimer()
    if m.mode <> "libraryVideo" or not m.recordingStartPending then return
    if m.libraryVideo.state = "playing"
        revealRecordedVideo()
    else
        ' If the player is buffering, keep the cover visible until it resumes.
        m.recordingQualityTimer.duration = 2
        m.recordingQualityTimer.control = "start"
    end if
end sub

sub revealRecordedVideo()
    m.recordingQualityTimer.control = "stop"
    m.recordingQualityWaitStarted = false
    m.recordingStartPending = false
    m.libraryVideo.visible = true
    m.recordingLoadingOverlay.visible = false
    m.liveOverlay.visible = false
    m.liveSpinner.control = "stop"
    m.liveSpinner.visible = false
end sub


' Spotify for Creators / Anchor RSS audio podcast integration (v87).
sub openPodcast()
    m.mode = "podcast"
    m.podcastLevel = "folders"
    m.podcastFolders = invalid
    m.podcastScreen.visible = true
    m.podcastStatus.text = "Loading sermon series and topics..."
    m.podcastList.content = CreateObject("roSGNode", "ContentNode")
    m.podcastTask = CreateObject("roSGNode", "PodcastTask")
    m.podcastTask.observeField("episodes", "onPodcastLoaded")
    m.podcastTask.control = "RUN"
end sub

' Use the first pipe only. Everything before it is the series/topic.
' Episodes without a pipe go into Other Sermons.
function podcastTitleParts(fullTitle as String) as Object
    pipePos = Instr(1, fullTitle, "|")
    seriesName = "Other Sermons"
    episodeName = fullTitle.Trim()
    if pipePos > 1 and pipePos < Len(fullTitle)
        candidate = Left(fullTitle, pipePos - 1).Trim()
        remainder = Mid(fullTitle, pipePos + 1).Trim()
        if candidate <> "" and remainder <> ""
            seriesName = candidate
            episodeName = remainder
        end if
    end if
    return {series: seriesName, episode: episodeName}
end function

sub onPodcastLoaded()
    if m.mode <> "podcast" then return
    episodes = m.podcastTask.episodes
    if episodes = invalid or episodes.getChildCount() = 0
        m.podcastStatus.text = "Podcast episodes are unavailable. Press BACK to return home."
        return
    end if

    groups = {}
    displayNames = {}
    for i = 0 to episodes.getChildCount() - 1
        item = episodes.getChild(i)
        parts = podcastTitleParts(item.title)
        key = LCase(parts.series)
        if not groups.DoesExist(key)
            groups[key] = []
            displayNames[key] = parts.series
        end if
        groups[key].Push({title: parts.episode, url: item.url, id: item.id, artwork: item.hdPosterUrl, date: item.shortDescriptionLine1})
    end for

    keys = groups.Keys()
    keys.Sort()
    m.podcastFolders = CreateObject("roSGNode", "ContentNode")
    for each key in keys
        folder = m.podcastFolders.CreateChild("ContentNode")
        folder.title = displayNames[key]
        folder.id = key
        folder.hdPosterUrl = "pkg:/images/podcast-header-muted.jpg"
        folder.shortDescriptionLine1 = groups[key].Count().ToStr() + " episodes  •  Press OK to browse"
        for each entry in groups[key]
            ep = folder.CreateChild("ContentNode")
            ep.title = entry.title
            ep.id = entry.id
            ep.url = entry.url
            ep.streamFormat = "mp3"
            ep.hdPosterUrl = entry.artwork
            ep.shortDescriptionLine1 = entry.date
        end for
    end for
    showPodcastFolders()
end sub

sub showPodcastFolders()
    m.podcastLevel = "folders"
    m.podcastList.content = m.podcastFolders
    m.podcastStatus.text = "SERMON SERIES & TOPICS  •  Select a folder"
    m.podcastList.jumpToItem = 0
    m.podcastList.setFocus(true)
end sub

sub openPodcastFolder()
    index = m.podcastList.itemFocused
    if index = invalid or index < 0 then return
    folder = m.podcastFolders.getChild(index)
    if folder = invalid then return
    m.podcastFolderIndex = index
    m.podcastLevel = "episodes"
    m.podcastList.content = folder
    m.podcastStatus.text = folder.title + "  •  Press OK to play audio"
    m.podcastList.jumpToItem = 0
    m.podcastList.setFocus(true)
end sub

sub playPodcastEpisode()
    index = m.podcastList.itemFocused
    if index = invalid or index < 0 then return
    episodes = m.podcastList.content
    if episodes = invalid then return
    item = episodes.getChild(index)
    if item = invalid or item.url = invalid or item.url = "" then return
    m.podcastScreen.visible = false
    playVideoItem(item, "podcast")
end sub



' v117 prototype: remote-driven navigation without altering existing content loaders.
sub showSideMenu()
    if m.mode = "startup" then return
    if m.top.dialog <> invalid then return
    m.menuOpen = true
    m.menuIndex = 0
    ' Transfer focus to the overlay so the underlying grid/list does not scroll.
    m.homeRows.setFocus(false)
    m.connectGrid.setFocus(false)
    m.podcastList.setFocus(false)
    if m.menuSelectionBg <> invalid then m.menuSelectionBg.translation = [16,136]
    m.menuHint.visible = false
    m.sideMenu.visible = true
    m.sideMenu.translation = [0, 0]
    m.top.setFocus(true)
end sub

sub hideSideMenu()
    m.menuOpen = false
    m.sideMenu.visible = false
    m.sideMenu.translation = [-340, 0]
    m.menuHint.visible = true
    if m.mode = "home"
        m.homeRows.setFocus(true)
    else if m.mode = "connect"
        m.connectGrid.setFocus(true)
    else if m.mode = "podcast"
        m.podcastList.setFocus(true)
    else
        m.top.setFocus(true)
    end if
end sub

sub moveSideMenuSelection(delta as Integer)
    nextIndex = m.menuIndex + delta
    if nextIndex < 0 then nextIndex = 8
    if nextIndex > 8 then nextIndex = 0
    m.menuIndex = nextIndex
    if m.menuSelectionBg <> invalid then m.menuSelectionBg.translation = [16, 136 + (m.menuIndex * 61)]
end sub

sub chooseSideMenuItem()
    ' Beta: Sermon Series uses the Archive.org VideoCatalogTask.
    selected = m.menuIndex
    ' Close the currently displayed section before routing to another one.
    ' Otherwise the old full-screen Group may obscure the new destination.
    resetScreensForMenuNavigation()
    ' Close the overlay without returning focus to the underlying RowList first.
    m.menuOpen = false
    m.sideMenu.visible = false
    m.sideMenu.translation = [-340, 0]
    m.menuHint.visible = false

    if selected = 0
        openHomeLanding()
    else if selected = 1
        ' Open the actual Watch Live screen, not merely focus its Home tile.
        openLive("Live Worship")
    else if selected = 2
        ' Recorded worship currently lives in the Latest Streams Home row.
        focusHomeSection(1)
    else if selected = 3
        openPodcast()
    else if selected = 4
        openConnect()
    else if selected = 5
        showStayConnectedChoice()
    else if selected = 6
        openPartner()
    else if selected = 8
        openVideoLibrary()
    else if selected = 7
        m.mode = "about"
        m.aboutScreen.visible = true
        m.top.setFocus(true)
    end if
    m.menuHint.visible = true
end sub

sub resetScreensForMenuNavigation()
    m.aboutScreen.visible = false
    m.connectScreen.visible = false
    m.connectDetailScreen.visible = false
    m.podcastScreen.visible = false
    m.videoLibraryScreen.visible = false
    m.sermonSeriesScreen.visible = false
    m.seriesVideosScreen.visible = false
    m.livePlayerScreen.visible = false
    m.podcastPlayerOverlay.visible = false
    m.liveVideo.control = "stop"
    m.liveSpinner.control = "stop"
    m.countdownTimer.control = "stop"
    m.bookmarkTimer.control = "stop"
    m.recordingQualityTimer.control = "stop"
end sub

sub openHomeLanding()
    m.homeSubpage = false
    m.mode = "home"
    m.homeRows.content = buildHomeRows(invalid, false)
    m.homeRows.numRows = 1
    m.homeRows.jumpToRowItem = [0, 0]
    m.homeRows.setFocus(true)
    showHomeIntro()
end sub

sub focusHomeSection(rowIndex as Integer)
    m.homeSubpage = true
    m.mode = "home"
    ' Restore the Latest Streams row only when its sidebar destination is opened.
    m.homeRows.content = buildHomeRows(invalid, true)
    m.homeRows.numRows = 2
    if rowIndex >= m.homeRows.content.getChildCount() then rowIndex = 0
    m.homeRows.jumpToRowItem = [rowIndex, 0]
    m.homeRows.setFocus(true)
end sub


' Confirm leaving the channel only when BACK is pressed on Home.
sub showExitConfirmation()
    if m.top.dialog <> invalid then return
    d = CreateObject("roSGNode", "Dialog")
    d.title = "Exit Versailles UMC?"
    d.message = "Would you like to close the Versailles UMC channel?"
    d.buttons = ["Keep Watching", "Exit Channel"]
    d.observeField("buttonSelected", "onExitConfirmationSelected")
    m.top.dialog = d
end sub

sub onExitConfirmationSelected()
    d = m.top.dialog
    if d = invalid then return
    selected = d.buttonSelected
    d.close = true
    if selected = 1
        m.top.exitRequested = true
    else
        m.homeRows.setFocus(true)
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press = false then return false

    if m.menuOpen
        if key = "right" or key = "back" or key = "left"
            hideSideMenu()
            return true
        end if
        if key = "up"
            moveSideMenuSelection(-1)
            return true
        else if key = "down"
            moveSideMenuSelection(1)
            return true
        else if key = "OK"
            chooseSideMenuItem()
            return true
        end if
        return true
    end if

    ' LEFT opens the sidebar from any browsing page. During recorded
    ' podcast playback, LEFT remains the existing 15-second seek control.
    if key = "left" and m.mode <> "libraryVideo" and m.mode <> "startup"
        showSideMenu()
        return true
    else if m.mode = "home" and key = "back"
        if m.homeSubpage = true
            openHomeLanding()
        else
            showExitConfirmation()
        end if
        return true
    end if

    if m.mode = "startup" then return true

    if m.mode = "podcast"
        if key = "back"
            if m.podcastLevel = "episodes"
                showPodcastFolders()
                m.podcastList.jumpToItem = m.podcastFolderIndex
            else
                m.podcastScreen.visible = false
                m.mode = "home"
                showHomeIntro()
                m.homeRows.setFocus(true)
            end if
            return true
        else if key = "OK"
            if m.podcastLevel = "folders"
                openPodcastFolder()
            else
                playPodcastEpisode()
            end if
            return true
        end if
        return false
    end if

    if m.mode = "about"
        if key = "back"
            m.aboutScreen.visible = false
            m.mode = "home"
            showHomeIntro()
            m.homeRows.setFocus(true)
            return true
        end if
        return true
    end if

    if m.mode = "connectDetail"
        if key = "back"
            m.connectDetailScreen.visible = false
            m.connectScreen.visible = true
            m.mode = "connect"
            m.connectGrid.setFocus(true)
            return true
        end if
        return true
    end if

    if m.mode = "connect"
        if key = "back"
            m.connectScreen.visible = false
            m.mode = "home"
            showHomeIntro()
            m.homeRows.setFocus(true)
            return true
        else if key = "OK"
            openSelectedConnectItem()
            return true
        end if
        return false
    end if

    if m.mode = "liveConnecting" or m.mode = "liveChoosing" or m.mode = "liveVideo" or m.mode = "liveOffAir"
        if key = "back"
            closeLive()
            return true
        end if
        return false
    end if

    if m.mode = "libraryVideo"
        if m.videoReturnMode = "podcast"
            if key = "OK" or key = "play"
                if m.libraryVideo.state = "paused"
                    m.libraryVideo.control = "resume"
                else
                    m.libraryVideo.control = "pause"
                end if
                return true
            else if key = "left" or key = "right"
                current = m.libraryVideo.position
                total = m.libraryVideo.duration
                if current = invalid then current = 0
                if key = "left" then current = current - 15 else current = current + 15
                if current < 0 then current = 0
                if total <> invalid and total > 1 and current > total - 1 then current = total - 1
                m.libraryVideo.seek = current
                return true
            end if
        end if
        if key = "back"
            saveCurrentBookmark()
            m.bookmarkTimer.control = "stop"
            m.recordingQualityTimer.control = "stop"
            m.recordingStartPending = false
            m.recordingLoadingOverlay.visible = false
            m.libraryVideo.control = "stop"
            m.livePlayerScreen.visible = false
            m.podcastPlayerOverlay.visible = false

            if m.videoReturnMode = "podcast"
                m.podcastScreen.visible = true
                m.mode = "podcast"
                m.podcastList.setFocus(true)
            else if m.videoReturnMode = "home"
                m.mode = "home"
                showHomeIntro()
                m.homeRows.setFocus(true)
            else
                m.mode = "seriesVideos"
                m.videoList.setFocus(true)
            end if

            return true
        end if
        return false
    end if

    if m.mode = "videos"
        if key = "back"
            m.videoLibraryScreen.visible = false
            m.mode = "home"
            showHomeIntro()
            m.homeRows.setFocus(true)
            return true
        else if key = "OK"
            openSelectedSection()
            return true
        end if
        return false
    end if

    if m.mode = "sermonSeries"
        if key = "back"
            if m.browseStack <> invalid and m.browseStack.Count() > 0
                previousNode = m.browseStack.Pop()
                showBrowseNode(previousNode)
            else
                m.sermonSeriesScreen.visible = false
                if m.libraryEntry = "home"
                    m.mode = "home"
                    showHomeIntro()
                    m.homeRows.setFocus(true)
                else
                    m.videoLibraryScreen.visible = true
                    m.mode = "videos"
                    m.seriesGrid.setFocus(true)
                end if
            end if
            return true
        else if key = "OK"
            openSelectedSermonSeries()
            return true
        end if
        return false
    end if

    if m.mode = "seriesVideos"
        if key = "back"
            m.seriesVideosScreen.visible = false
            if m.returnMode = "sermonSeries"
                m.sermonSeriesScreen.visible = true
                m.mode = "sermonSeries"
                m.sermonSeriesGrid.setFocus(true)
            else if m.returnMode = "home"
                m.mode = "home"
                showHomeIntro()
                m.homeRows.setFocus(true)
            else
                m.videoLibraryScreen.visible = true
                m.mode = "videos"
                m.seriesGrid.setFocus(true)
            end if
            return true
        else if key = "OK"
            playLibraryVideo()
            return true
        end if
        return false
    end if

    return false
end function
