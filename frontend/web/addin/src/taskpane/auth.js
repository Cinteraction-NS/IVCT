// import axios from "axios";

 async function signInEmailPass(email, password) {
  console.log("calledFunc");

  const loginUrl = "https://huawei.nswebdevelopment.com/api/login";

  try {
    const response = await axios.post(
      loginUrl,
      { email, password },
      {
        headers: {
          "Content-Type": "application/json",
        },
      }
    );

    const loginResponse = response.data;
    return { success: true, data: loginResponse };
  } catch (error) {
    return {
      success: false,
      error: error.response ? error.response.data : error.message,
    };
  }
}

 async function scheduleMeet(name, description, tag, startDateTime, timezone, accessToken) {
  const scheduleUrl = "https://huawei.nswebdevelopment.com/api/meetings/schedule";

  const params = {
    name,
    description,
    tag,
    startDateTime,
    timezone,
  };

  try {
    const response = await axios.post(scheduleUrl, params, {
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
    });
    return { success: true, data: response.data };
  } catch (error) {
    console.error("Schedule error:", error.response ? error.response.data : error.message);
    return {
      success: false,
      error: error.response ? error.response.data : error.message,
    };
  }

}

function meet()
{
  console.log("test function");
}

window.scheduleMeet = scheduleMeet;
window.meet = meet;
window.signInEmailPass = signInEmailPass;

console.log("scheduleMeet and meet functions are now available on window.");

