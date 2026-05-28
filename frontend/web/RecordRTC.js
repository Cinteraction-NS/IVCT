//    function mergeVideos(blobs) {
//      console.log('kokot srdjan')
//
//<!--      if (typeof FFmpeg === "undefined") {-->
//<!--        console.error("FFmpeg is not loaded yet!");-->
//<!--        return;-->
//<!--      }-->
//
//      const ffmpeg = FFmpeg.createFFmpeg({ log: true });
//
//      async function process() {
//        await ffmpeg.load();
//
//        blobs.forEach(async (blob, index) => {
//          const fileName = `input${index}.mp4`;
//          ffmpeg.FS('writeFile', fileName, new Uint8Array(await blob.arrayBuffer()));
//        });
//
//        await ffmpeg.run('-i', 'concat:input0.mp4|input1.mp4', '-c', 'copy', 'output.mp4');
//
//        const data = ffmpeg.FS('readFile', 'output.mp4');
//        const outputBlob = new Blob([data.buffer], { type: 'video/mp4' });
//        const outputUrl = URL.createObjectURL(outputBlob);
//
//        console.log(outputUrl);
//      }
//
//      process();
//    }

//      try {
//        // Run FFmpeg command to merge videos
//    <!--    await ffmpeg.run(-->
//    <!--  '-f', 'concat',-->
//    <!--  '-safe', '0',-->
//    <!--  '-i', 'fileList.txt',-->
//    <!--  '-c:v', 'copy',  // Use the existing VP8 video codec-->
//    <!--  '-c:a', 'copy',  // Copy the existing audio codec-->
//    <!--  'output.webm'-->
//    <!--);-->