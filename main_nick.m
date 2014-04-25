%% rECoGnition
% BE521 Final Project
%   by Team Alphabet(12:14)
%       Laura Struzyna
%       Nicholas McGill
%       Mohammed Shahid
% 
% Main File



%% Initialize
clear all; close all; clc;

%% Nick
addpath('/Users/nmcgill/Dropbox/upenn/be521/ieeg.stuff/ieeg-matlab-1.6.11/IEEGToolbox')
addpath('/Users/nmcgill/Projects/githubbed/rECoGnition')
username = 'nmcgill';
pw = 'nmc_ieeglogin.bin';


%% Start session and pull in first data set
session = IEEGSession('I521_A0009_D001',username,pw);
openDataSet(session,  'I521_A0009_D002');
openDataSet(session,  'I521_A0009_D003');
openDataSet(session,  'I521_A0010_D001');
openDataSet(session,  'I521_A0010_D002');
openDataSet(session,  'I521_A0010_D003');
openDataSet(session,  'I521_A0011_D001');
openDataSet(session,  'I521_A0011_D002');
openDataSet(session,  'I521_A0011_D003');

% Subject 1 Data
s1_train_ecog   = session.data(1);
s1_train_glove  = session.data(2);
s1_test_ecog    = session.data(3);

% Subject 2 Data
s2_train_ecog   = session.data(4);
s2_train_glove  = session.data(5);
s2_test_ecog    = session.data(6);

% Subject 3 Data
s3_train_ecog   = session.data(7);
s3_train_glove  = session.data(8);
s3_test_ecog    = session.data(9);



