//go:build !goose

package main

import (
	"fmt"
	"time"
)

func main() {
	// This simple example creates a new time stamp, then marshals and unmarshals it into
	// a new TimeStamp before printing the result.

	hours, minutes, seconds := time.Now().Clock()
	fmt.Printf("True Time:   %02d:%02d:%02d\n", hours, minutes, seconds)
	timeStamp := TimeStamp{hour: uint32(hours), minute: uint32(minutes), second: uint32(seconds)}
	enc := MarshalTimeStamp(&timeStamp)

	var newTime *TimeStamp
	newTime = UnmarshalTimeStamp(enc)

	fmt.Printf("Struct Time: %02d:%02d:%02d\n", newTime.hour, newTime.minute, newTime.second)
}
