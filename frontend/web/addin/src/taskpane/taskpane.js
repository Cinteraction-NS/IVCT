// import { signInEmailPass } from "./auth";

// Office.onReady((info) => {
//   initializeApp();
//   if (info.host === Office.HostType.Outlook) {
//     initializeApp();
//     console.log("Office version: ", Office.context.diagnostics.officeVersion);
//   }
// });

// Wait for the DOM to be fully loaded
document.addEventListener("DOMContentLoaded", () => {
  initializeApp();
  Office.onReady((info) => {
    if (info.host === Office.HostType.Outlook) {
      console.log("Office version: ", Office.context.diagnostics.officeVersion);
    }
   
  });

  function initializeApp() {
    const accessToken = localStorage.getItem("accessToken");
    const loginForm = document.getElementById("login-form");
    const signOutSection = document.getElementById("signOutSection");

    if (accessToken) {
      loginForm.style.display = "none";
      signOutSection.style.display = "block";
    } else {
      loginForm.style.display = "block";
      signOutSection.style.display = "none";
    }

    document.getElementById("signInButton").onclick = runSignIn;
    document.getElementById("signOutButton").onclick = signOut;
  }

  async function runSignIn() {
    const emailInput = document.getElementById("emailInput");
    const passwordInput = document.getElementById("passwordInput");
    const spinner = document.getElementById("spinner");
    const errorMsg = document.getElementById("errorMsg");

    const email = emailInput.value.trim();
    const password = passwordInput.value.trim();

    errorMsg.textContent = "";

    if (!email || !password) {
      errorMsg.textContent = "Both email and password are required.";
      return;
    }

    spinner.style.display = "block";
    const loginResult = await window.signInEmailPass(email, password);
    spinner.style.display = "none";

    if (loginResult.success) {
      localStorage.setItem("accessToken", loginResult.data.access_token);
      initializeApp();
    } else {
      errorMsg.textContent = "Email or password not verified.";
    }
  }

  function signOut() {
    localStorage.removeItem("accessToken");
    initializeApp();
  }
});

