const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.send("✅ Auth Service running inside Docker!");
});

app.listen(3000, () => {
  console.log("Server listening on port 3000");
});
// Last final check to trigger CI/CD pipeline