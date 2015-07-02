# Blinky Tape

Add the Blink Tape device to your gateblu using Octoblu. Or create a meshblu.json for this library to run independently.

See this article for more details: https://www.hackster.io/royvandewater/blinky-tape

# Install Manually

1. Clone this repo
  - `git clone [repo-url]`
1. Go into directory
  - `cd meshblu-blinky-tape`
1. Install Meshblu Util
  - `npm install meshblu-util -g`
1. Create Meshblu.json
  - `meshblu-util register > meshblu.json`
1. Claim in Octoblu
  - `meshblu-util claim`

# Messaging the device

Send a message to the device with the property animation, which is an array of frames. Each frame contains an array of colors. A color can be anything accepted by tinycolor, for example, red, black, green, rbg(23, 23, 45), #00ff00, etc.

### Example use of function node:


````
function getColorFrame(color){
  return _.times(100, function(){
    return color;
  });
}
var animation = [
  getColor('black'),
  getColor('green'),
  getColor('blue'),
  getColor('red'),
  getColor('purple'),
  getColor('blue'),
  getColor('yellow'),
  getColor('green'),
  getColor('blue'),
  getColor('purple'),
  getColor('red'),
  getColor('red')
];

return {
  animation: animation
}
````
