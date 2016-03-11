function ALLfileinfo = CFF_save_mat_from_all(ALLfile, MATfilename)
% ALLfileinfo = CFF_save_mat_from_all(ALLfile, MATfilename)
%
% DESCRIPTION
%
% Saves the fields in structure ALLfile (obtained from
% CFF_read_all_from_fileinfo) into a .MAT file whose name given by
% MATfilename. Also saves ALLfile.info as separate variable ALLfileinfo for
% backwards compatibility with CFF_convert_all_to_mat
%
% USE
%
%
%
% PROCESSING SUMMARY
% 
%
%
% REQUIRED INPUT ARGUMENTS
%
% - 'ALLfile': structure containing structures for each datagram type.
%
% - 'MATfilename': string of the name of the file to output.
%
% OUTPUT VARIABLES
%
% - ALLfileinfo (optional): structure for description of the datagrams in
% input file. Fields are: 
%   * ALLfilename: input file name
%   * filesize: file size in bytes
%   * datagsizeformat: endianness of the datagram size field 'b' or 'l'
%   * datagramsformat: endianness of the datagrams 'b' or 'l'
%   * datagNumberInFile: 
%   * datagTypeNumber: for each datagram, SIMRAD datagram type in decimal
%   * datagTypeText: for each datagram, SIMRAD datagram type description
%   * parsed: for each datagram, 1 if datagram has been parsed, 0 if not
%   * counter: the counter of this type of datagram in the file (ie
%   first datagram of that type is 1 and last datagram is the total number
%   of datagrams of that type).
%   * number: the number/counter found in the datagram (usually
%   different to counter)
%   * size: for each datagram, datagram size in bytes
%   * syncCounter: for each datagram, the number of bytes founds between
%   this datagram and the previous one (any number different than zero
%   indicates a sunc error
%   * emNumber: EM Model number (eg 2045 for EM2040c)
%   * date: datagram date in YYYMMDD
%   * timeSinceMidnightInMilliseconds: time since midnight in msecs 
%
% RESEARCH NOTES
%
%
%
% NEW FEATURES
%
% - 2015-09-30:
%   - first version taking from last version of convert_all_to_mat
%
% EXAMPLES
%
% ALLfilename = '.\DATA\RAW\0001_20140213_052736_Yolla.all';
%
% tic
% info = CFF_all_file_info(ALLfilename);
% info.parsed(:)=1; % to save all the datagrams
% ALLfile = CFF_read_all_from_fileinfo(ALLfilename, info);
% ALLfileinfo1 = CFF_save_mat_from_all(ALLfile, 'temp1.mat');
% clear ALLfile
% toc
%
% % using old conversion function:
% tic
% ALLfileinfo2 = CFF_convert_all_to_mat(ALLfilename, 'temp2.mat');
% toc
%
%%%
% Alex Schimel, Deakin University
%%%


save(MATfilename, '-struct', 'ALLfile');%'-v7.3'
ALLfileinfo = ALLfile.info;


