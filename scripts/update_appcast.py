import os

version      = os.environ["VERSION"]
build_number = os.environ["BUILD_NUMBER"]
ed_signature = os.environ["ED_SIGNATURE"]
zip_size     = os.environ["ZIP_SIZE"]
pub_date     = os.environ["PUB_DATE"]
download_url = os.environ["DOWNLOAD_URL"]

new_item = (
    "        <item>\n"
    f"            <title>Version {version}</title>\n"
    f"            <sparkle:version>{build_number}</sparkle:version>\n"
    f"            <sparkle:shortVersionString>{version}</sparkle:shortVersionString>\n"
    f"            <pubDate>{pub_date}</pubDate>\n"
    "            <sparkle:minimumSystemVersion>15.0</sparkle:minimumSystemVersion>\n"
    "            <enclosure\n"
    f'                url="{download_url}"\n'
    f'                sparkle:edSignature="{ed_signature}"\n'
    f'                length="{zip_size}"\n'
    '                type="application/octet-stream"/>\n'
    "        </item>"
)

with open("appcast.xml", "r") as f:
    content = f.read()

content = content.replace("    </channel>", new_item + "\n    </channel>")

with open("appcast.xml", "w") as f:
    f.write(content)
