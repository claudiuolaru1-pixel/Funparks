const { GoogleAuth } = require("google-auth-library");

async function main() {
  const auth = new GoogleAuth({
    keyFile: "./serviceAccountKey.json",
    scopes: ["https://www.googleapis.com/auth/firebase"],
  });
  const client = await auth.getClient();
  const accessToken = (await client.getAccessToken()).token;

  const appId = "1:50958281106:ios:13a3a93c1e9cae612e794b";
  const url = `https://firebase.googleapis.com/v1beta1/projects/funparks-779c6/iosApps/${appId}:undelete`;

  const res = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
  });
  const data = await res.json();
  console.log("Status:", res.status);
  console.log(JSON.stringify(data, null, 2));
}

main().catch(err => console.error("Error:", err));