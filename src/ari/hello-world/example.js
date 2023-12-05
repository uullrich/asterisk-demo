/**
 *  This example shows how channel dtmf events can be used to playback sounds on
 *  a channel and to hangup the channel.
 *
 *  @namespace example
 *
 *  @copyright 2014, Digium, Inc.
 *  @license Apache License, Version 2.0
 *  @author Samuel Fortier-Galarneau <sgalarneau@digium.com>
 *  @example <caption>Dialplan</caption>
 *  exten => 7000,1,NoOp()
 *      same => n,Stasis(example)
 *      same => n,Hangup()
 */

"use strict";

const client = require("ari-client");

async function runDialplan() {
  const ari = await client.connect(
    "http://127.0.0.1:8088",
    "asterisk",
    "asterisk"
  );
  console.log("Connected!");

  // Use once to start the application
  ari.on(
    "StasisStart",
    /**
     *  Setup event listeners for dtmf events, answer channel that entered
     *  Stasis and play hello world greeting to the channel.
     *
     *  @callback stasisStartCallback
     *  @memberof example
     *  @param {Object} event - the full event object
     *  @param {module:resources~Channel} incoming -
     *    the channel that entered Stasis
     */
    async (event, incoming) => {
      // Handle DTMF events
      incoming.on(
        "ChannelDtmfReceived",
        /**
         *  Handle the dtmf event appropriately. # will hangup the channel,
         *  * will play a sound on the channel, and all digits will be played
         *  back on the channel.
         *
         *  @callback channelDtmfReceivedCallack
         *  @memberof example
         *  @param {Object} event - the full event object
         *  @param {module:resources~Channel} channel - the channel that
         *    received the dtmf event
         */
        async (event, channel) => {
          const { digit } = event;
          try {
            switch (digit) {
              case "#":
                await play(channel, "sound:vm-goodbye");
                channel.hangup();
                process.exit(0);
              case "*":
                await play(channel, "sound:tt-monkeys");
                break;
              default:
                await play(channel, `sound:digits/${digit}`);
            }
          } catch (error) {
            console.log(error);
          }
        }
      );

      try {
        await incoming.answer();
        await play(incoming, "sound:hello-world");
      } catch (error) {
        console.log(error);
      }
    }
  );

  /**
   *  Initiate a playback on the given channel.
   *
   *  @function play
   *  @memberof example
   *  @param {module:resources~Channel} channel - the channel to send the
   *    playback to
   *  @param {string} sound - the string identifier of the sound to play
   *  @returns {Q} promise - a promise that will resolve to the finished
   *                         playback
   */
  async function play(channel, sound) {
    const playback = ari.Playback();

    return new Promise(async (resolve, reject) => {
      playback.once("PlaybackFinished", (event, playback) => {
        resolve(playback);
      });

      try {
        await channel.play({ media: sound }, playback);
      } catch {
        reject(err);
      }
    });
  }

  // can also use ari.start(['app-name'...]) to start multiple applications
  ari.start("example");
}

runDialplan();
