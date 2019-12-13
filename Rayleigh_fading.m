function rvs = Rayleigh_fading(fs, fD, mean_value, nr_samples)
% fs = Sample rate (Hz) (= number of samples / second)
% fD = Maximum Doppler shift (Hz) 
% mean_value = mean value of your random variables
% nrSamples = Number of samples (Number of random variables that you get)

t_start = tic;
rchan = comm.RayleighChannel('SampleRate', fs, ...
                             'MaximumDopplerShift', fD, ...
                             'FadingTechnique', 'Sum of sinusoids');
                         
R = rchan(ones(nr_samples,1))';

rvs = mean_value.*(real(R).^2 + imag(R).^2);
toc(t_start)

end