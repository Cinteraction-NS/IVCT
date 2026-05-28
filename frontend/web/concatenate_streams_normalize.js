function downloadMergedVideo(url) {
  const a = document.createElement("a");
  a.href = url;
  a.download = "merged_video.webm"; // Suggested filename
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
}

async function getBlobFromUrl(blobUrl) {
  // Create a new Request object using the Blob URL
  const response = await fetch(blobUrl);

  // The response object contains the Blob data
  const blob = await response.blob();

  return blob;
}

async function concatenateVideos(blobUrls) {
    const { createFFmpeg, fetchFile } = FFmpeg;
    const ffmpeg = createFFmpeg({ log: true });
  //
    await ffmpeg.load();
  // Convert Blob URLs to Blobs
  const blobs = await Promise.all(blobUrls.map(getBlobFromUrl));
//    downloadIndividualVideos(blobs)
  //    blobs.forEach((blob, index) => uploadBlob(blob, `video${index}.webm`));

  // Write the Blob files to FFmpeg
  for (let i = 0; i < blobs.length; i++) {
    let fileName = `input${i}.webm`;
    ffmpeg.FS("writeFile", fileName, await fetchFile(blobs[i])); // Pass the Blob to FFmpeg
  }

  // Create file list for FFmpeg concatenation
  let fileList = blobs.map((_, i) => `file 'input${i}.webm'`).join("\n");
  ffmpeg.FS("writeFile", "fileList.txt", new TextEncoder().encode(fileList));

  let normalizedVideos = [];
  for (let i = 0; i < blobs.length; i++) {
    let inputFile = `input${i}.webm`;
    let outputFile = `normalized${i}.webm`;

try {
    await ffmpeg.run(
      "-i", inputFile,
      "-r", "24",
      "-c:v", "copy",
      "-c:a", "copy",
      outputFile
    );

    const data = ffmpeg.FS("readFile", outputFile);
    normalizedVideos.push({
      name: outputFile,
      blob: new Blob([data.buffer], { type: "video/webm" }),
    });
} catch (error) {
    // Code to handle the error
    console.error('An error occurred:', error.message);
}

  }

  for (let video of normalizedVideos) {
    ffmpeg.FS("writeFile", video.name, await fetchFile(video.blob));
  }

  // Create file list for FFmpeg
  let fileListt = normalizedVideos.map((v) => `file '${v.name}'`).join("\n");
  ffmpeg.FS("writeFile", "fileListN.txt", new TextEncoder().encode(fileListt));

  // Run FFmpeg to merge videos using copy codec
  await ffmpeg.run(
    "-f", "concat",
    "-safe", "0",
    "-i", "fileListN.txt",
    "-c", "copy",
    "output.webm"
  );

  // Get merged video
  const data = ffmpeg.FS("readFile", "output.webm");
  // Create a downloadable link
  const videoBlob = new Blob([data.buffer], { type: "video/webm" });
  const url = URL.createObjectURL(videoBlob);
  const a = document.createElement("a");
  a.href = url;
  a.download = "merged_video.webm";
  document.body.appendChild(a);
  a.click();
  URL.revokeObjectURL(url);
}

// Assuming `blobs` is an array containing the individual video blobs
function downloadIndividualVideos(blobs) {
  blobs.forEach((blob, index) => {
    const videoBlobUrl = URL.createObjectURL(blob); // Create Blob URL for each video

    // Create a link element to trigger the download
    const link = document.createElement("a");
    link.href = videoBlobUrl;
    link.download = `participant_${index + 1}_video.webm`; // Name the file based on index
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    // Revoke the Blob URL to release memory
    URL.revokeObjectURL(videoBlobUrl);
  });
}

async function uploadBlob(blob, filename) {
  const formData = new FormData();
  formData.append("file", blob, filename);

  try {
    const response = await fetch("http://localhost:3001/upload", {
      method: "POST",
      body: formData,
    });

    if (!response.ok) throw new Error("Upload failed");

    console.log("Upload successful:", filename);
  } catch (error) {
    console.error("Error uploading file:", error);
  }
}
