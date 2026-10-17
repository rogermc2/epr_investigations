import numpy as np
from scipy.stats import binom

#################################################################################
#Load the data
#################################################################################

# Two datasets corresponding to before and after replacement of one of the APD's at location C, see Section "APD replacement" in  Hensen et al. arXiv:1603.05705.
data_filepath_old_detector  = r'bell_open_data_2_old_detector.txt'
data_filepath_new_detector  = r'bell_open_data_2_new_detector.txt'

a_i = np.array([],dtype=np.int64)
b_i = np.array([],dtype=np.int64)
x_i = np.array([],dtype=np.int64)
y_i = np.array([],dtype=np.int64)
t_i = np.array([],dtype=np.int64)
s_i = np.array([],dtype=np.int64)

#the new APD has a different calibrated detection-to-output delay.
event_ready_window_start_channel0_old_detector = 5426000 # picoseconds after last sync-pulse
event_ready_window_start_channel0_new_detector = event_ready_window_start_channel0_old_detector - 700 #picoseconds. 
#With these two different window_starts, we combine the two datasets:
for event_ready_window_start_channel0, data_filepath in zip([event_ready_window_start_channel0_old_detector,event_ready_window_start_channel0_new_detector],
                                                            [data_filepath_old_detector,data_filepath_new_detector]):

    # For a detailed description of the data please see online Supplementary Information sections E, H, I, J, K & N of Hensen et al. Nature  526, 682 (2015).
    # Data contains all attempts that had the following two-photon signature recorded at location C: one photon detection between 5415000 - 5665000 (window 1) 
    # picoseconds after sync-pulse and one between 5665000 - 5915000 (window 2) picoseconds after sync-pulse as recorded at location C.
    event_ready_timestamp       = np.loadtxt(data_filepath,delimiter=',', skiprows=0, usecols=[0], dtype=np.datetime64)
    data                        = np.loadtxt(data_filepath,delimiter=',', skiprows=0, usecols=np.arange(1,17), dtype=np.int64)
    day_number                  = data[:,0]  # identifier for the measurement day, in between measurement days various optimisation measurements are performed,                                  
    run_number                  = data[:,1]  # identifier for the measurement run, in between measurement runs various calibrations are performed, 
                                             #see Supplementary Information, Section J

    event_ready_click1_time     = data[:,2]  # window 1 detection time picoseconds after sync-pulse
    event_ready_click1_channel  = data[:,3]  # window 1 detection channel
    event_ready_click2_time     = data[:,4]  # window 2 detection time picoseconds after sync-pulse
    event_ready_click2_channel  = data[:,5]  # window 2 detection channel
                                             #see Supplementary Information, Section E

    random_number_A             = data[:,6]  # random number recorded at location A
    random_number_B             = data[:,7]  # random number recorded at location B
    random_number_A_time        = data[:,8]  # random number recording time, nanosecond after sync-pulse at location A
    random_number_B_time        = data[:,9]  # random number recording time, nanosecond after sync-pulse at location B
    readout_click_A_time        = data[:,10] # detection time of first PSB photon in window 10620 - 14620 ns after sync-pulse, at location A. 0 if no detection events in window
    readout_click_B_time        = data[:,11] # detection time of first PSB photon in window 10620 - 14620 ns after sync-pulse, at location B. 0 if no detection events in window
                                             #see Supplementary Information, Section K

    click_after_excite_A_time   = data[:,12] # detection time of first PSB photon in windows 7480 - 7680 & 7730 - 7930 ns after sync-pulse, at location A. 0 if no detection events in both windows
    click_after_excite_B_time   = data[:,13] # detection time of first PSB photon in windows 5350 - 5550 & 5600 - 5800 ns after sync-pulse, at location B. 0 if no detection events in both windows
    last_invalid_marker_A       = data[:,14] # number of sync-pulses since last recorded invalid-marker I. 0 if none recorded in current data run at location A
    last_invalid_marker_B       = data[:,15] # number of sync-pulses since last recorded invalid-marker I. 0 if none recorded in current data run at location B
                                             #see Supplementary Information, Sections J & K

    #################################################################################
    # Analysis parameters
    #################################################################################

    # Valid event-ready signals, defined in Supplementary Information, Section E
    #event_ready_window_start_channel0     defined above
    event_ready_window_start_channel1      = 5425100 # picoseconds after last sync-pulse
    event_ready_window_length              = 50000   # picoseconds
    event_ready_window_separation          = 250000  # picoseconds

    # To limit the effect of to APD after-pulsing, only a short part of the second detection 
    # window is taken for the psi-plus heralding events (two detections in the same detector).
    # Here the exponentially decaying NV emission still dominates the detection probability.
    event_ready_second_window_length_psi_plus_channel0 = 4000 # picoseconds
    event_ready_second_window_length_psi_plus_channel1 = 2500 # picoseconds

    # Readout window, defined in e.g. Figure 2 
    readout_window_start                   = 10620          # nanoseconds after last sync-pulse
    readout_window_length                  = 3700           # nanoseconds
    check_for_invalid_marker_in_past       = 250            # number of attemps (sync-pulses)


    #################################################################################
    # Filters defining valid Bell trials: 
    #################################################################################

    # See Supplementary Information, Section K
    event_ready_window1_channel0_filter =   ((event_ready_window_start_channel0 <= event_ready_click1_time)\
                                           & (event_ready_click1_time < (event_ready_window_start_channel0 + event_ready_window_length))\
                                           & (event_ready_click1_channel == 0))
    event_ready_window1_channel1_filter =   ((event_ready_window_start_channel1 <= event_ready_click1_time)\
                                           & (event_ready_click1_time < (event_ready_window_start_channel1 + event_ready_window_length))\
                                           & (event_ready_click1_channel == 1))
    event_ready_window1_filter          = event_ready_window1_channel0_filter | event_ready_window1_channel1_filter

    event_ready_window2_channel0_psi_min_filter =  ((event_ready_window_start_channel0 + event_ready_window_separation <= event_ready_click2_time)\
                                                 & (event_ready_click2_time < (event_ready_window_start_channel0 + event_ready_window_separation + event_ready_window_length))\
                                                 & (event_ready_click2_channel == 0))
    event_ready_window2_channel1_psi_min_filter =  ((event_ready_window_start_channel1 + event_ready_window_separation <= event_ready_click2_time)\
                                                 & (event_ready_click2_time < (event_ready_window_start_channel1 + event_ready_window_separation + event_ready_window_length))\
                                                 & (event_ready_click2_channel == 1))
    event_ready_window2_channel0_psi_plus_filter = ((event_ready_window_start_channel0 + event_ready_window_separation <= event_ready_click2_time)\
                                                 & (event_ready_click2_time < (event_ready_window_start_channel0 + event_ready_window_separation + event_ready_second_window_length_psi_plus_channel0))\
                                                 & (event_ready_click2_channel == 0))
    event_ready_window2_channel1_psi_plus_filter = ((event_ready_window_start_channel1 + event_ready_window_separation <= event_ready_click2_time)\
                                                 & (event_ready_click2_time < (event_ready_window_start_channel1 + event_ready_window_separation + event_ready_second_window_length_psi_plus_channel1))\
                                                 & (event_ready_click2_channel == 1))

    event_ready_window2_psi_min_filter  = event_ready_window2_channel0_psi_min_filter  | event_ready_window2_channel1_psi_min_filter
    event_ready_window2_psi_plus_filter = event_ready_window2_channel0_psi_plus_filter | event_ready_window2_channel1_psi_plus_filter

    event_ready_psi_min_filter          = (event_ready_click1_channel != event_ready_click2_channel)
    event_ready_psi_plus_filter         = np.logical_not(event_ready_psi_min_filter)
    event_ready_window_filter           = (event_ready_window1_filter & event_ready_window2_psi_min_filter  & event_ready_psi_min_filter )\
                                        | (event_ready_window1_filter & event_ready_window2_psi_plus_filter & event_ready_psi_plus_filter)

    no_invalid_marker_A_filter          = ((last_invalid_marker_A == 0) | (last_invalid_marker_A > check_for_invalid_marker_in_past))
    no_invalid_marker_B_filter          = ((last_invalid_marker_B == 0) | (last_invalid_marker_B > check_for_invalid_marker_in_past))
    no_invalid_marker_AB_filter         = (no_invalid_marker_A_filter & no_invalid_marker_B_filter)

    no_excitation_click_AB_filter       = (click_after_excite_A_time == 0) & (click_after_excite_B_time == 0)

    bell_trial_filter                   = (event_ready_window_filter & no_invalid_marker_AB_filter & no_excitation_click_AB_filter)

    #################################################################################
    # Checking for local readout photon detection clicks at locations A and B:
    #################################################################################

    # See Supplementary Information, Section K
    detection_in_readout_window_A       =  (readout_click_A_time > readout_window_start)\
                                                    & (readout_click_A_time <= readout_window_start + readout_window_length)  
    detection_in_readout_window_B       =  (readout_click_B_time > readout_window_start)\
                                                     & (readout_click_B_time <= readout_window_start + readout_window_length)

    # Variables corresponding to those used in the statistical analysis, 
    # see Supplementary Information Section N
    a_i = np.append(a_i,random_number_A)
    b_i = np.append(b_i,random_number_B)
    x_i = np.append(x_i,detection_in_readout_window_A*2-1)
    y_i = np.append(y_i,detection_in_readout_window_B*2-1)
    t_i = np.append(t_i,bell_trial_filter.astype(np.int64)*(event_ready_psi_plus_filter.astype(np.int64)*2-1))


#################################################################################
# Statistical Analysis
#################################################################################
# Calculate the p-value, see Supplementary Information Section N, and Section "Joint P-value for psi- and psi+ heralded events" of Hensen et al. arXiv:1603.05705.
n   = np.sum(np.abs(t_i)) #number of bell trials
c_i = np.abs(t_i) * ((-1)**((a_i)*(b_i+(t_i+1)/2)) * (x_i*y_i) + 1)/2
k   = np.sum(c_i)
tau     = 5.4e-6*2 #see Supplementary Information Section I
ksi    = 3./4+3*(tau+tau**2) 
p_value =  1-binom.cdf(k-1, n, ksi)

print '-'*40
print 'k/n: {}/{}'.format(k,n)
print 'p-value : {:.3f}'.format(p_value)

for psi in [+1,-1]:
    print '-'*40
    print 'psi_plus' if psi==+1 else 'psi_min'
    # Matrix containing correlations (a,b,x,y) obtained for the valid trials:
    inputs_ab  = [[0,0],[0,1],[1,0],[1,1]] #'RND (a,b) = (0,0); (0,1); (1,0); (1,1); '
    outputs_xy = [[+1,+1],[+1,-1],[-1,+1],[-1,-1]] #'RO (x,y) = (+1,+1); (+1,-1); (-1,+1); (-1,-1); 
    correlation_matrix      = np.zeros((4,4), dtype=np.int64)
    xy_ab_correlation       = np.zeros(4) 
    xy_ab_correlation_error = np.zeros(4)
    for ii,(a,b) in enumerate(inputs_ab):
        for jj,(x,y) in enumerate(outputs_xy):
            correlation_matrix[ii,jj] =  np.sum(
                                                 (t_i == psi)\
                                                 & (a_i == a)\
                                                 & (b_i == b)\
                                                 & (x_i == x)\
                                                 & (y_i == y)
                                             )
        # Calculate the <x.y>_(a,b), as defined in equation (1) of the main text
        xy_ab_correlation[ii]       = (correlation_matrix[ii,0] - correlation_matrix[ii,1] - correlation_matrix[ii,2] + correlation_matrix[ii,3])/float(np.sum(correlation_matrix[ii,:]))
        xy_ab_correlation_error[ii] = np.sqrt((1-xy_ab_correlation[ii]**2)/float(np.sum(correlation_matrix[ii,:])))

    # Calculate the CHSH S parameter
    S_error = np.sqrt(xy_ab_correlation_error[0]**2 + xy_ab_correlation_error[1]**2 + xy_ab_correlation_error[2]**2 + xy_ab_correlation_error[3]**2)
    if psi==+1:
        S_psi_plus = xy_ab_correlation[0] + xy_ab_correlation[1] - xy_ab_correlation[2] + xy_ab_correlation[3]
        S = S_psi_plus
        S_error_psi_plus = S_error
        n_psi_plus = np.sum(correlation_matrix)
    else:
        S_psi_min = xy_ab_correlation[0] + xy_ab_correlation[1] + xy_ab_correlation[2] - xy_ab_correlation[3]
        S = S_psi_min
        S_error_psi_min = S_error
        n_psi_min = np.sum(correlation_matrix)

    print 'xy     ++,+-,-+,--'
    print 'ab 00', correlation_matrix[0], '  (0,    -3pi/4)'
    print 'ab 01', correlation_matrix[1], '  (0,    +3pi/4)'
    print 'ab 10', correlation_matrix[2], '  (pi/2, -3pi/4)'
    print 'ab 11', correlation_matrix[3], '  (pi/2, +3pi/4)\n'

    print ' E (RND00  RND01  RND10  RND11 )'
    print '   ({:+.3f}, {:+.3f}, {:+.3f}, {:+.3f}) measured'.format(*xy_ab_correlation)
    print '+/-( {:.3f},  {:.3f},  {:.3f},  {:.3f} )'.format(*xy_ab_correlation_error)

    print 'CHSH S : {:.3f} +- {:.3f}'.format(S, S_error)

n_tot = n_psi_min+n_psi_plus
S_combined = n_psi_plus/float(n_tot)*S_psi_plus + n_psi_min/float(n_tot)*S_psi_min
S_error_combined = np.sqrt((n_psi_plus/float(n_tot))**2*S_error_psi_plus**2+(n_psi_min/float(n_tot))**2*S_error_psi_min**2)

print '-'*40
print 'psi_plus, psi_min combined'
print 'CHSH S : {:.3f} +- {:.3f}'.format(S_combined, S_error_combined)
