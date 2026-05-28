/*
 * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

const accessToken = localStorage.getItem("accessToken");

function onMessageSendHandler(event) {
  if (accessToken) {
    fetchMeetingDetails(event);
  } else {
    showLogin(event);
  }
}

async function fetchMeetingDetails(event) {

  const item = Office.context.mailbox.item;

  const getSubject = () => {
    return new Promise((resolve, reject) => {
    
      item.subject.getAsync((result) => {
        if (result.status === Office.AsyncResultStatus.Succeeded) {
          resolve(result.value);
        } else {
          reject(new Error(result.error.message));
        }
      });
    });
  };

  const getStartTime = () => {
    return new Promise((resolve, reject) => {
      item.start.getAsync((result) => {
        if (result.status === Office.AsyncResultStatus.Succeeded) {
          resolve(result.value);
        } else {
          reject(new Error(result.error.message));
        }
      });
    });
  };

  const formatStartTime = (isoString) => {
    const date = new Date(isoString);
    date.setMinutes(date.getMinutes());
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, "0");
    const day = String(date.getDate()).padStart(2, "0");
    const hours = String(date.getHours()).padStart(2, "0");
    const minutes = String(date.getMinutes()).padStart(2, "0");

    return `${year}-${month}-${day} ${hours}:${minutes}`;
  };

  try {
    const [subject, startTimeIso] = await Promise.all([getSubject(), getStartTime()]);

    if (subject && subject.trim() !== "" && startTimeIso) {
      const formattedStartTime = formatStartTime(startTimeIso);
      console.log("Formatted StartTime:", formattedStartTime);

      try {
        await window.scheduleMeet(subject, subject, "", formattedStartTime, "Europe/Belgrade", accessToken);
        console.log("Meeting successfully scheduled.");
      } catch (error) {
        console.error("Error scheduling the meeting:", error);
      }
    } else {
      console.warn("ScheduleMeet not called: missing subject or startTime.");
    }

    event.completed({ allowEvent: true });
  } catch (error) {
    console.error("Failed to retrieve subject or start time:", error.message);
    event.completed({ allowEvent: true });
  }
}

function showLogin(event) {
  event.completed({
    allowEvent: false,
    errorMessage: "You are not authorized!",
  });
}

Office.actions.associate("onMessageSendHandler", onMessageSendHandler);
