function icath = convert_shot(shot_data, co_gain, x_gain, pol)

shot_data = double(shot_data);

if strcmp(pol,'co')
    vlog = 0.0017333*shot_data(1:1000) - 0.42262;       % V
    vlog = 1.41421*vlog;                                % Account for 3dB attenuator
    vlin = 10.^(-8*(0.486+vlog));                       % Convert to positive value
    icath = vlin/(50*co_gain);                          % Photocathode current
end

if strcmp(pol,'x')
    vlog = 0.00173536*shot_data(1001:2000) - 0.42225;   % V
    vlog = 1.41421*vlog;                                % Account for 3dB attenuator
    vlin = 10.^(-8*(0.486+vlog));                       % Convert to positive value
    icath = vlin/(50*x_gain);                           % Photocathode current
end

if strcmp(pol,'de')
    vlog = 0.0017333*shot_data(1:1000) - 0.42262;       % V
    vlog = 1.41421*vlog;                                % Account for 3dB attenuator
    vlin = 10.^(-8*(0.486+vlog));                       % Convert to positive value
    icath_co = vlin/(50*co_gain);                       % Photocathode current
    
    vlog = 0.00173536*shot_data(1001:2000) - 0.42225;   % V
    vlog = 1.41421*vlog;                                % Account for 3dB attenuator
    vlin = 10.^(-8*(0.486+vlog));                       % Convert to positive value
    icath_x = vlin/(50*x_gain);                         % Photocathode current
    
    icath = icath_x ./ icath_co;
end

end