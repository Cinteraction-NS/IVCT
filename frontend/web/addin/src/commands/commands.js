/*
 * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

/* global Office */

{
  /* <script type="text/javascript" src="../launchevent/launchevent.js"></script>; */
}

function generateRandomNumber() {
  // Generate a random 6-digit number
  const randomNumber = Math.floor(100000 + Math.random() * 900000);
  return randomNumber;
}

// Handler za ItemSend

function action(event) {
  const meetingId = generateRandomNumber();

  const bodyContent = `
  <div style="font-family:Arial, sans-serif; padding: 10px; font-size: 14px;">
      <img src="https://huawei.nswebdevelopment.com/web/addin/assets/cinteraction_logo.png" alt="Cinteraction" title="Cinteraction" />
      </br>
      </br>
      <p>
          Join the meeting:
          <a href="https://huawei.nswebdevelopment.com/web/home/meeting/${meetingId}" target="_blank" style="color: #46139A; text-decoration: none;">
            https://huawei.nswebdevelopment.com/web/home/meeting/${meetingId}
          </a>
      </p>
      </br>
      <hr>
      <p style="font-size: 12px; color: #888;">
          This meeting invite was created using the Outlook Add-in.
      </p>
  </div>
  `;

  // Set the dynamically generated content with the meeting link into the email body
  Office.context.mailbox.item.body.setAsync(
    bodyContent,
    {
      coercionType: "html", // Specify HTML format
    },
    function (asyncResult) {
      if (asyncResult.status == Office.AsyncResultStatus.Failed) {
        console.error("Error setting body:", asyncResult.error.message);
      }
    }
  );

  // Be sure to indicate when the add-in command function is complete.
  event.completed();
}

// Register the function with Office.
Office.actions.associate("action", action);
