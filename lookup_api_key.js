const { GoogleAuth } = require("google-auth-library");

async function main() {
  const auth = new GoogleAuth({
    keyFile: "./serviceAccountKey.json",
    scopes: ["https://www.googleapis.com/auth/cloud-platform"],
  });
  const client = await auth.getClient();
  const accessToken = (await client.getAccessToken()).token;

  const keyId = "85bfd98a-1a6f-4575-a1f6-99c1bec2f45d";
  const url = `https://apikeys.googleapis.com/v2/projects/funparks-779c6/locations/global/keys/${keyId}`;

  const res = await fetch(url, {
    method: "GET",
    headers: { Authorization: `Bearer ${accessToken}` },
  });
  const data = await res.json();
  console.log("Status:", res.status);
  console.log(JSON.stringify(data, null, 2));
}

main().catch(err => console.error("Error:", err));