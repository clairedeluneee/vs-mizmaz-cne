var funkinTitle:String = window.title;
function new() {
  window.title = "Vs. MizMaz";
}
function destroy() {
  window.title = funkinTitle;
}
