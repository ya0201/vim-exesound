#! /usr/bin/env python
# -*- coding: utf-8 -*-
#  vim: set ts=4 sw=4 tw=0 noet :
#======================================================================
#
# exesound2.py - play sound on Windows/OS X/Linux
#
# Created by skywind on 2018/05/02
# Last Modified: 2018/05/02 15:48:59
#
#======================================================================
from __future__ import print_function
import sys
import os
import time
import sdl2
import sdl2.sdlmixer


#----------------------------------------------------------------------
# 2/3 compatible
#----------------------------------------------------------------------
if sys.version_info[0] >= 3:
	long = int
	unicode = str
	xrange = range


#----------------------------------------------------------------------
# SDL2 sound
#----------------------------------------------------------------------
class AudioPlayback (object):

	def __init__ (self):
		if sdl2.SDL_Init(sdl2.SDL_INIT_AUDIO) != 0:
			raise RuntimeError("Cannot initialize audio system: {}".format(sdl2.SDL_GetError()))
		fmt = sdl2.sdlmixer.MIX_DEFAULT_FORMAT
		if sdl2.sdlmixer.Mix_OpenAudio(44100, fmt, 2, 1024) != 0:
			raise RuntimeError("Cannot open mixed audio: {}".format(sdl2.sdlmixer.Mix_GetError()))
		sdl2.sdlmixer.Mix_AllocateChannels(64)
		self._bank_se = {}
		self._bgm = None

	def load_se (self, filename):
		filename = os.path.abspath(filename)
		uuid = os.path.normcase(filename)
		if uuid not in self._bank_se:
			if not isinstance(filename, bytes):
				filename = filename.encode('utf-8')
			sample = sdl2.sdlmixer.Mix_LoadWAV(filename)
			if sample is None:
				return None
			self._bank_se[uuid] = sample
		return self._bank_se[uuid]

	def load_bgm (self, filename):
		filename = os.path.abspath(filename)
		if not isinstance(filename, bytes):
			filename = filename.encode('utf-8')
		self._bgm = sdl2.sdlmixer.Mix_LoadMUS(filename)
		if self._bgm is None:
			return -1
		return 0

	def play_se (self, sample, channel = -1):
		channel = sdl2.sdlmixer.Mix_PlayChannel(channel, sample, 0)
		if channel < 0:
			return -1
		return channel

	def play_bgm (self):
		sdl2.sdlmixer.Mix_PlayMusic(self._bgm, -1)
		return 0

	def stop_bgm (self):
		sdl2.sdlmixer.Mix_HaltMusic()
		return 0

	def is_se_playing (self, channel):
		return sdl2.sdlmixer.Mix_Playing(channel)

	def set_volume (self, channel, volume = 1.0):
		if channel < 0:
			return False
		volint = int(volume * sdl2.sdlmixer.MIX_MAX_VOLUME)
		sdl2.sdlmixer.Mix_Volume(channel, volint)
		return True


#----------------------------------------------------------------------
# playsound
#----------------------------------------------------------------------
_playback = None

def play_se(path, volume = 1.0, channel = -1):
	global _playback
	if _playback is None:
		_playback = AudioPlayback()
	sample = _playback.load_se(path)
	if sample is not None:
		hr = _playback.play_se(sample, channel)
		if hr >= 0:
			_playback.set_volume(hr, volume)
		return hr
	return None

def start_bgm(path, volume = 1.0, channel = -1):
	global _playback
	if _playback is None:
		_playback = AudioPlayback()
	if _playback.load_bgm(path) == 0:
		_playback.play_bgm()
		return 0
	return -1

def stop_bgm():
	global _playback
	if _playback is None:
		return -1
	_playback.stop_bgm()



#----------------------------------------------------------------------
# choose theme
#----------------------------------------------------------------------
def choose_theme(theme):
	import vim
	for rtp in vim.eval('&rtp').split(','):
		path = os.path.abspath(os.path.join(rtp, 'sounds/' + theme))
		if os.path.exists(path):
			if os.path.exists(os.path.join(path, 'keyany.wav')):
				if path[-1:] in ('/', '\\'):
					path = path[:-1]
				return path
	return ''


#----------------------------------------------------------------------
# testing case
#----------------------------------------------------------------------
if __name__ == '__main__':

	def test1():
		ap = AudioPlayback()
		print('haha')
		sp = ap.load_se("../sounds/typewriter/keyenter.wav")
		if not sp:
			print('bad sample')
		print('play: ', ap.play_se(sp, channel = 2))
		start_bgm("../sounds/typewriter/keyany.wav")
		time.sleep(5)
		stop_bgm()
		#  ap.play_bgm()
		# raw_input()
		sys.stdin.read(1)
		print('play: ', ap.play_se(sp))
		sys.stdin.read(1)
		# raw_input()
		return 0

	def test2():
		while 1:
			for i in xrange(100):
				time.sleep(0.10)
				print(play_se('../sounds/mario/keyany.wav'))
			print('stop ?')
			text = raw_input()
			if text == 'yes':
				break
		print('exit')
		sys.stdin.read(1)

	test1()

