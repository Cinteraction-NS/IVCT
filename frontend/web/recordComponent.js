//class VideoRecorder {
//  constructor() {
//    this.videoElement = null;
//    this.recordVideoElement = null;
//    this.mediaRecorder = null;
//    this.recordedBlobs = [];
//    this.isRecording = false;
//    this.downloadUrl = null;
//    this.stream = null;
//  }
//
//  async init() {
//    this.videoElement = document.getElementById('video');
//    this.recordVideoElement = document.getElementById('recordedVideo');
//
//    try {
//      const stream = await navigator.mediaDevices.getUserMedia({
//        video: { width: 360 }
//      });
//      this.stream = stream;
//      this.videoElement.srcObject = this.stream;
//
//      // Expose functions to the global window object
//      window.startRecording = this.startRecording.bind(this);
//      window.stopRecording = this.stopRecording.bind(this);
//    } catch (error) {
//      console.error('Error accessing media devices:', error);
//    }
//  }
//
//  function startRecording(stream) {
//    this.recordedBlobs = [];
//    const options = { mimeType: 'video/webm' };
//
//    try {
//      this.mediaRecorder = new MediaRecorder(stream, options);
//    } catch (err) {
//      console.log('Error creating media recorder:', err);
//      return;
//    }
//
//    this.mediaRecorder.start();
//    this.isRecording = !this.isRecording;
//    this.onDataAvailableEvent();
//    this.onStopRecordingEvent();
//  }
//
//  stopRecording() {
//    this.mediaRecorder.stop();
//    this.isRecording = !this.isRecording;
//    console.log('Recorded Blobs: ', this.recordedBlobs);
//  }
//
//  playRecording() {
//    if (!this.recordedBlobs || !this.recordedBlobs.length) {
//      console.log('Cannot play. No recorded video.');
//      return;
//    }
//    this.recordVideoElement.play();
//  }
//
//  onDataAvailableEvent() {
//    try {
//      this.mediaRecorder.ondataavailable = (event) => {
//        if (event.data && event.data.size > 0) {
//          this.recordedBlobs.push(event.data);
//        }
//      };
//    } catch (error) {
//      console.log('Error handling ondataavailable event:', error);
//    }
//  }
//
//  onStopRecordingEvent() {
//    try {
//      this.mediaRecorder.onstop = () => {
//        const videoBuffer = new Blob(this.recordedBlobs, { type: 'video/webm' });
//        this.downloadUrl = window.URL.createObjectURL(videoBuffer);
//        this.recordVideoElement.src = this.downloadUrl;
//      };
//    } catch (error) {
//      console.log('Error handling onstop event:', error);
//    }
//  }
//}
//
//// Initialize the video recorder
//const videoRecorder = new VideoRecorder();
//videoRecorder.init();
