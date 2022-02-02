from time import sleep
#import subprocess
import os
import atexit

import click

import gpxpy
import gpxpy.gpx

def cmd(cmds):
	try:
		os.system(cmds)
	except subprocess.CalledProcessError as e:
		raise e

def upload_diskimage(version="14.5"):
	# uplaod diskimage file with idiskimagemounter FILE FILE_SIGNATURE
	pass

def validate_pair():
	cmd(['idevicepair', 'validate'])

def simulate_coords(lat, lon):
	cmd('/opt/local/bin/idevicesetlocation -- {} {}'.format(lat, lon))

@atexit.register
def reset_location():
	cmd('/opt/local/bin/idevicesetlocation reset')

@click.command()
@click.option('--speed', default=1.0, help='Amount of Seconds to wait inbetween Coords.')
@click.option('--file', required=True, help='GPX File used as input.')
def main(file, speed):
	"""Simulates Location on iPhone, takes a GPX File as input"""
	try:
		gpx_file = open(file, 'r')
	except Exception as e:
		raise e

	gpx = gpxpy.parse(gpx_file)

	for track in gpx.tracks:
		for segment in track.segments:
			for point in segment.points:
				simulate_coords(point.latitude, point.longitude)
				print('Simulated move to ({0},{1})'.format(point.latitude, point.longitude))
				sleep(speed)

if __name__ == '__main__':
	main()
