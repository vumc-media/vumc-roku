// VUMC Archive.org catalog experiment — deploy as a separate Cloudflare Worker.
// Routes: /series.json (nested series and videos), /videos.xml (Media RSS).
const UPLOADER = "versaillesumcworshipteam@gmail.com";
const SEARCH = "https://archive.org/advancedsearch.php";
const ARCHIVE = "https://archive.org";
const escapeXml = s => String(s ?? "").replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;").replace(/'/g,"&apos;");
const asList = v => Array.isArray(v) ? v : (v ? [v] : []);
function tagsFor(m) {
  return asList(m.subject).flatMap(v => String(v).split(";")).map(v => v.trim()).filter(Boolean);
}
function dateFor(m) {
  const d = String(m.date || "").slice(0,10);
  if (/^\d{4}-\d{2}-\d{2}$/.test(d)) return d;
  return String(m.publicdate || m.addeddate || "").slice(0,10);
}
async function getJson(url) {
  const r = await fetch(url, {headers:{"Accept":"application/json"}});
  if (!r.ok) throw new Error("Archive request failed: " + r.status);
  return r.json();
}
async function catalog() {
  const q = new URL(SEARCH);
  q.searchParams.set("q", 'uploader:"' + UPLOADER + '" AND mediatype:movies');
  for (const field of ["identifier","title","publicdate"]) q.searchParams.append("fl[]", field);
  q.searchParams.append("sort[]", "publicdate desc");
  q.searchParams.set("rows","1000");
  q.searchParams.set("output","json");
  const search = await getJson(q);
  const docs = search.response?.docs || [];
  const entries = await Promise.all(docs.map(async doc => {
    try {
      const item = await getJson(ARCHIVE + "/metadata/" + encodeURIComponent(doc.identifier));
      const m = item.metadata || {};
      const tags = tagsFor(m);
      const video = (item.files || []).find(f => f.source === "original" && /\.mp4$/i.test(f.name))
        || (item.files || []).find(f => /\.mp4$/i.test(f.name));
      if (!video) return null;
      const seriesTag = tags.find(t => /^series:/i.test(t));
      const typeTag = tags.find(t => /^type:/i.test(t));
      const serviceTag = tags.find(t => /^service:/i.test(t));
      const type = typeTag ? typeTag.slice(5).trim().toLowerCase() : "";
      const series = seriesTag ? seriesTag.slice(7).trim() : "";
      const service = serviceTag ? serviceTag.slice(8).trim().toLowerCase() : "";
      // Sermons only: keep full services out of the sermon-series grid.
      if (type !== "sermon" || !series || service) return null;
      const base = ARCHIVE + "/download/" + encodeURIComponent(doc.identifier) + "/";
      const thumbnail = (item.files || []).find(f => f.name === "__ia_thumb.jpg");
      return {
        id: doc.identifier, title: m.title || doc.title || doc.identifier,
        date: dateFor(m), series, tags,
        videoUrl: base + video.name.split("/").map(encodeURIComponent).join("/"),
        thumbnailUrl: thumbnail ? base + encodeURIComponent(thumbnail.name) : "",
        duration: Math.round(Number(video.length || 0)),
        description: String(m.description || "").replace(/<[^>]*>/g," ").trim()
      };
    } catch (e) { return null; }
  }));
  const videos = entries.filter(Boolean).sort((a,b) => b.date.localeCompare(a.date) || a.title.localeCompare(b.title));
  const grouped = new Map();
  for (const video of videos) {
    if (!grouped.has(video.series)) grouped.set(video.series, []);
    grouped.get(video.series).push(video);
  }
  const series = [...grouped].map(([title, items]) => ({
    id: title.toLowerCase().replace(/[^a-z0-9]+/g,"-").replace(/^-|-$/g,""),
    title, latestDate: items[0].date, thumbnailUrl: items[0].thumbnailUrl, videos: items
  })).sort((a,b) => b.latestDate.localeCompare(a.latestDate));
  return {updatedAt: new Date().toISOString(), series, videos};
}
function xmlFeed(videos) {
  const items = videos.map(v => `<item><title>${escapeXml(v.title)}</title><guid isPermaLink="false">${escapeXml(v.id)}</guid><pubDate>${new Date(v.date+"T12:00:00Z").toUTCString()}</pubDate><description>${escapeXml(v.description)}</description><category>${escapeXml(v.series)}</category><enclosure url="${escapeXml(v.videoUrl)}" type="video/mp4"/><media:content url="${escapeXml(v.videoUrl)}" medium="video" type="video/mp4" duration="${v.duration}"/><media:thumbnail url="${escapeXml(v.thumbnailUrl)}"/></item>`).join("");
  return `<?xml version="1.0" encoding="UTF-8"?><rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/"><channel><title>VUMC Sermons</title><description>Versailles UMC sermon archive</description>${items}</channel></rss>`;
}
export default {
  async fetch(request) {
    const path = new URL(request.url).pathname;
    if (path !== "/series.json" && path !== "/videos.xml") return new Response("Use /series.json or /videos.xml", {status:404});
    try {
      const result = await catalog();
      const xml = path === "/videos.xml";
      return new Response(xml ? xmlFeed(result.videos) : JSON.stringify(result), {
        headers:{"content-type":xml ? "application/rss+xml; charset=utf-8" : "application/json; charset=utf-8",
          "cache-control":"public, max-age=300", "access-control-allow-origin":"*"}
      });
    } catch (e) { return new Response("Catalog temporarily unavailable", {status:503}); }
  }
};
