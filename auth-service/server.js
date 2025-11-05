const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.send("✅ Auth Service v2 running inside Docker!");
});

app.listen(3000, () => {
  console.log("Server listening on port 3000");
});
// One last push to trigger CI/CD pipeline