 function downloadMergedVideo(url) {
        const a = document.createElement('a');
        a.href = url;
        a.download = 'merged_video.mkv'; // Suggested filename
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

      function getColumns(itemCount) {
          if (itemCount === 1) return 1;
          if (itemCount > 1 && itemCount < 5) return 2;
          return 3;
      }

  async function mergeVideos(blobUrls) {
//    const blobUrls = urls.flatMap(url => [url]);
  // Write the Blob files to FFmpeg
  console.log("-----------mergeVideos------------");
    for (let i = 0; i < blobUrls.length; i++) {
      console.log(blobUrls[i]);
    }
  console.log("-----------------------------------");


    const { createFFmpeg, fetchFile } = FFmpeg;
    const ffmpeg = createFFmpeg({ log: true });
    await ffmpeg.load();

     console.log("------------ ffmpeg loaded -------------");
    // Convert Blob URLs to Blobs
    const blobs = await Promise.all(blobUrls.map(getBlobFromUrl));

    // Write the Blob files to FFmpeg
    for (let i = 0; i < blobs.length; i++) {
        let fileName = `input${i}.webm`;
        ffmpeg.FS('writeFile', fileName, await fetchFile(blobs[i]));
    }

  let fileList = blobs.map((_, i) => `'-i', 'input${i}.webm',`).join("\n");
  let inputArgs = [];
  for (let i = 0; i < blobs.length; i++) {
      inputArgs.push('-i', `input${i}.webm`);
  }

   const maxGridWidth = 960;
   const maxGridHeight = 720;

  // Define the number of columns (you can change this based on your needs)
  const columns = getColumns(blobs.length) ;
  const rows = Math.ceil(blobs.length / columns);

   // Define the base size for the grid
  const gridWidth = maxGridWidth * columns / 3;
  const gridHeight =  maxGridHeight * rows / 3;

   const itemWidth = maxGridWidth / 3;
   const itemHeight = maxGridHeight / 3;

  // Initialize filter_complex string
  let filterComplex = `nullsrc=size=${gridWidth}x${gridHeight} [base];`;

  // Add the video processing steps for each input video
  let overlays = `[base][v0] overlay=shortest=1 [tmp0]`;
    if (blobs.length > 1) {
           overlays += `;`; // Add semicolon only if it's not the last item
       }

  for (let i = 0; i < blobs.length; i++) {
    const xPos = (i % columns) * (gridWidth / columns); // Horizontal position
    const yPos = Math.floor(i / columns) * (gridHeight / rows); // Vertical position

    filterComplex += `[${i}:v] setpts=PTS-STARTPTS, scale=${itemWidth}:${itemHeight} [v${i}]; `;
     if (i > 0) {
          overlays += `[tmp${i - 1}][v${i}] overlay=shortest=1:x=${xPos}:y=${yPos}`;
          if (i < blobs.length - 1) {
              overlays += `[tmp${i}] ;`; // Add semicolon only if it's not the last item
          }
      }
  }
  // Complete filter_complex
  filterComplex += overlays;
  // Run FFmpeg with dynamic filter_complex
  console.log('trying to get video');
  if(blobs.length > 1)
  {
    await ffmpeg.run(
      ...inputArgs,
      '-filter_complex', filterComplex,
      '-c:v', 'libx264',
      'output.mkv'
    );
  }
  else
  {
    await ffmpeg.run(
      ...inputArgs,
      '-c:v', 'libx264',
      'output.mkv'
    );
  }
    // Get the merged video
    const data = ffmpeg.FS('readFile', 'output.mkv');

    // Create a downloadable link
    const videoBlob = new Blob([data.buffer], { type: 'video/mkv' });
    const url = URL.createObjectURL(videoBlob);
    downloadMergedVideo(url);
}
