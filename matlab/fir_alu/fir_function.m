% Parameters       
num_samples = 100;
num_taps = 64;

% Generate 16-bit fixed-point input signals (1 signed bit, 8 integer bits, 7 fractional bits)
x_bin = strings(num_samples, 1);  % binary
x_in = zeros(num_samples, 1);     % 16 bits decimal
x = zeros(num_samples, 1);        % 16 bits FX
for i = 1:num_samples
    % 1 bit sign bit
    x_sign_bit = num2str(randi([0, 1]));
    % 8 bits integer part
    x_integer_part_bin = dec2bin(randi([0, 255]), 8);
    % 7 bits fraction part
    x_fraction_part_bin = dec2bin(randi([0, 127]), 7);
    
    x_bin(i) = strcat(x_sign_bit, x_integer_part_bin, x_fraction_part_bin);
    x_in(i) = bin2dec(x_bin(i));

    sign = 1 - 2 * str2double(x_sign_bit); % if sign = 1 -> positive, -1 -> negative
    integer_part = bin2dec(x_integer_part_bin);
    if (sign < 0)
        integer_part = 256 - integer_part;
    end
    fractional_part = bin2dec(x_fraction_part_bin) * 0.0078125;
    
    % FX-16 bits
    x(i) = sign * integer_part + fractional_part;

end

% Generate 16-bit fixed-point filter coefficients (1 signed bit, 2 integer bits, 13 fractional bits)
b_bin = strings(num_taps, 1);  % binary
b_in = zeros(num_taps, 1);     % 16 bits decimal
b = zeros(num_taps, 1);        % 16 bits FX
for i = 1:num_taps
    % 1 bit sign bit
    b_sign_bit = num2str(randi([0, 1]));
    % 2 bits integer part
    b_integer_part_bin = dec2bin(randi([0, 3]), 2);
    % 13 bits fraction part
    b_fraction_part_bin = dec2bin(randi([0, 8191]), 13);
    
    b_bin(i) = strcat(b_sign_bit, b_integer_part_bin, b_fraction_part_bin);
    b_in(i) = bin2dec(b_bin(i));

    sign = 1 - 2 * str2double(b_sign_bit); % if sign = 1 -> positive, -1 -> negative
    integer_part = bin2dec(b_integer_part_bin);
    if (sign < 0)
        integer_part = 4 - integer_part;
    end
    fractional_part = bin2dec(b_fraction_part_bin) * 0.00012207031;
    
    % FX-16 bits
    b(i) = sign * integer_part + fractional_part;

end

[y_fixed, y_float] = fir_filters(x, b);

% save inputs and filter coefficients in to files
file_x = fopen('input_data.txt', 'w');
file_b = fopen('filter_coeff.txt', 'w');
%fprintf(file_x, '%.7f\n', x);
%fprintf(file_b, '%.11f\n', b);
fprintf(file_x, '%d\n', x_in);
fprintf(file_b, '%d\n', b_in);
fclose(file_x);
fclose(file_b);
% save outputs
file_yfx = fopen('output_FX.txt', 'w');
fprintf(file_yfx, '%.11f\n', y_fixed);
file_yfp = fopen('output_FP.txt', 'w');
fprintf(file_yfp, '%d\n', y_float);
fclose(file_yfx);
fclose(file_yfp);


% Function Definitions
%
% Custom MAC of FIR filter
function [y_fixed, y_float] = fir_filters(x, b)
    % Number of input samples and filter taps
    num_samples = length(x);
    num_taps = length(b);
    
    y_fixed = zeros(num_samples, 1); % Fixed-point output vector
    y_float = zeros(num_samples, 1);
    for n = 1:num_samples

        % Accumulated sum for the current output sample
        acc_sum = 0.0;
        
        % Perform the multiply-accumulate operation
        for i = 1:num_taps
            if (n - i + 1) >= 1
                acc_sum = acc_sum + b(i) * x(n - i + 1);
            end
        end
        % FX 32bits (1 sign bit + 11 integer bits + 20 fractional bits)
        y_fixed(n) = acc_sum;
        y_float(n) = fixed_to_fp16(acc_sum);
    end
end

function fp16 = fixed_to_fp16(fx_value)
    % Convert a 32-bit fixed-point number to a 16-bit floating-point representation
    % The floating-point format is 1 sign bit, 5 exponent bits, 10 mantissa bits

    % Define constants
    SIGN_BIT_POSITION = 15;
    EXPONENT_BITS = 5;
    MANTISSA_BITS = 10;
    EXPONENT_BIAS = 15;
    MAX_EXPONENT = 31;  % 5-bit max value (2^5 - 1)

    % Handle special case for zero
    if fx_value == 0
        fp16 = uint16(0);
        return;
    end

    % Determine sign bit
    sign_bit = fx_value < 0;
    abs_value = abs(fx_value);

    % Calculate exponent (log2) and normalize the mantissa
    exponent = floor(log2(abs_value));
    normalized_mantissa = abs_value / (2^exponent);

    % Adjust exponent to be within range and add bias
    exponent = exponent + EXPONENT_BIAS;

    % Handle cases where exponent goes out of bounds
    if exponent >= MAX_EXPONENT
        exponent = MAX_EXPONENT;        % Set to max exponent
        mantissa = (2^MANTISSA_BITS) - 1;  % Set mantissa to max (for infinity representation)
    elseif exponent <= 0
        exponent = 0;
        mantissa = 0;  % Subnormal case or zero
    else
        % Scale mantissa to 10 bits and round
        mantissa = floor((normalized_mantissa - 1) * (2^MANTISSA_BITS));
        if mantissa >= 2^MANTISSA_BITS
            mantissa = (2^MANTISSA_BITS) - 1;  % Clamp mantissa if it exceeds 10 bits
        end
    end

    % Combine sign, exponent, and mantissa into a 16-bit floating-point format
    fp16 = uint16(bitshift(double(sign_bit), SIGN_BIT_POSITION) + bitshift(exponent, MANTISSA_BITS) + mantissa);
    return;
end