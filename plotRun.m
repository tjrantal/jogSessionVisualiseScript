fclose all;
close all;
clear all;
clc;
%Requires signal package (sudo aptitude install octave-signal)
% on octave command line pkg load -auto signal 
pkg load signal
addpath('functions');
constants = struct();
constants.dataPath = 'data';
recurseDataFolder(constants.dataPath,'./',constants);

