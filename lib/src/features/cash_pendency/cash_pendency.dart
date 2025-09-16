import 'package:cash_pendency/src/features/cash_pendency/cash_pendency_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CashPendency extends StatefulWidget {
  const CashPendency({super.key});

  @override
  State<CashPendency> createState() => _CashPendencyState();
}

CashPendencyProvider? cashPendencyProvider;

class _CashPendencyState extends State<CashPendency> {
  List<bool> selectedStates = [];
  List<bool> selectedCompanies = [];
  String selectedDate = '';
  String selectedState = '';
  String selectedCompany = '';
  DateTime _focusedDay = DateTime.now();
  DateTime? selectedDay;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Set today's date as default
    final now = DateTime.now();
    selectedDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    selectedDay = now;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (cashPendencyProvider == null) {
      cashPendencyProvider = Provider.of<CashPendencyProvider>(
        context,
        listen: false,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadInitialData();
      });
    }
  }

  void _loadInitialData() async {
    await cashPendencyProvider!.getState();
    await cashPendencyProvider!.getCompany();

    if (cashPendencyProvider!.stateList.isNotEmpty) {
      // Set first state as selected
      selectedStates = List.filled(
        cashPendencyProvider!.stateList.length,
        false,
      );
      selectedStates[0] = true;
      selectedState = cashPendencyProvider!.stateList[0].text ?? '';
    }

    if (cashPendencyProvider!.companyList.isNotEmpty) {
      // Set first company as selected
      selectedCompanies = List.filled(
        cashPendencyProvider!.companyList.length,
        false,
      );
      selectedCompanies[0] = true;
      selectedCompany = cashPendencyProvider!.companyList[0].text ?? '';
    }

    setState(() {}); // Update UI

    if (cashPendencyProvider!.stateList.isNotEmpty) {
      cashPendencyProvider!.getCashPendencyGroupReport(
        selectedDate,
        _selectedTabIndex == 0 ? 'BRANCH_ID' : 'TYP_ID',
        cashPendencyProvider!.companyList.isNotEmpty
            ? cashPendencyProvider!.companyList[0].id
            : null,
        [cashPendencyProvider!.stateList[0].id!],
      );
    }
  }

  void _applyFilter() {
    String? selectedCompanyId;
    List<String> selectedStateIds = [];

    // Get selected company ID
    for (int i = 0; i < cashPendencyProvider!.companyList.length; i++) {
      if (i < selectedCompanies.length && selectedCompanies[i]) {
        selectedCompanyId = cashPendencyProvider!.companyList[i].id;
        break;
      }
    }

    // Get selected state IDs
    for (int i = 0; i < cashPendencyProvider!.stateList.length; i++) {
      if (i < selectedStates.length && selectedStates[i]) {
        selectedStateIds.add(cashPendencyProvider!.stateList[i].id ?? '');
      }
    }

    // If no states selected, use first state as default
    if (selectedStateIds.isEmpty &&
        cashPendencyProvider!.stateList.isNotEmpty) {
      selectedStateIds.add(cashPendencyProvider!.stateList[0].id ?? '');
    }

    print(
      'Applying filter with: date=$selectedDate, company=$selectedCompanyId, states=$selectedStateIds',
    );

    cashPendencyProvider!.getCashPendencyGroupReport(
      selectedDate,
      _selectedTabIndex == 0 ? 'BRANCH_ID' : 'TYP_ID',
      selectedCompanyId,
      selectedStateIds,
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        'Filter',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B1B),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              selectedDate,
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'State',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await _showStateBottomSheet();
                                  setModalState(() {});
                                },
                                child: Text(
                                  'Select State >',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (selectedState.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFFF6B1B),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                selectedState,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: const Color(0xFFFF6B1B),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Company',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await _showCompanyBottomSheet();
                                  setModalState(() {});
                                },
                                child: Text(
                                  'Select Company >',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (selectedCompany.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFFF6B1B),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                selectedCompany,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: const Color(0xFFFF6B1B),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFF6B1B)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setModalState(() {
                            final now = DateTime.now();
                            selectedDate =
                                '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                            selectedState = '';
                            selectedCompany = '';
                          });
                        },
                        child: Text(
                          'Reset',
                          style: GoogleFonts.montserrat(
                            color: const Color(0xFFFF6B1B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _applyFilter();
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B1B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Apply',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFilterOption(String title, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: value == title ? Colors.grey : Colors.black,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _focusedDay = picked;
        selectedDate =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _showCompanyBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => Consumer<CashPendencyProvider>(
        builder: (context, provider, child) => StatefulBuilder(
          builder: (context, setModalState) {
            if (selectedCompanies.length != provider.companyList.length) {
              selectedCompanies = List.filled(
                provider.companyList.length,
                false,
              );
            }
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            'Companies',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(
                          provider.companyList.length,
                          (index) => CheckboxListTile(
                            title: Text(
                              provider.companyList[index].text ?? '',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            value: selectedCompanies[index],
                            activeColor: const Color(0xFFFF6B1B),
                            checkColor: Colors.white,
                            onChanged: (value) {
                              setModalState(() {
                                for (
                                  int i = 0;
                                  i < selectedCompanies.length;
                                  i++
                                ) {
                                  selectedCompanies[i] = false;
                                }
                                selectedCompanies[index] = value ?? false;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFFF6B1B)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setModalState(() {
                                selectedCompanies = List.filled(
                                  provider.companyList.length,
                                  false,
                                );
                              });
                            },
                            child: Text(
                              'Reset',
                              style: GoogleFonts.montserrat(
                                color: const Color(0xFFFF6B1B),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Update selected company
                              for (
                                int i = 0;
                                i < provider.companyList.length;
                                i++
                              ) {
                                if (selectedCompanies[i]) {
                                  selectedCompany =
                                      provider.companyList[i].text ?? '';
                                  break;
                                }
                              }
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B1B),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'Apply',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showStateBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => Consumer<CashPendencyProvider>(
        builder: (context, provider, child) => StatefulBuilder(
          builder: (context, setModalState) {
            if (selectedStates.length != provider.stateList.length) {
              selectedStates = List.filled(provider.stateList.length, false);
            }
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            'States',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(
                          provider.stateList.length,
                          (index) => CheckboxListTile(
                            title: Text(
                              provider.stateList[index].text ?? '',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            value: selectedStates[index],
                            activeColor: const Color(0xFFFF6B1B),
                            checkColor: Colors.white,
                            onChanged: (value) {
                              setModalState(() {
                                // Clear all selections first
                                for (
                                  int i = 0;
                                  i < selectedStates.length;
                                  i++
                                ) {
                                  selectedStates[i] = false;
                                }
                                // Set only the current selection
                                selectedStates[index] = value ?? false;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFFF6B1B)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setModalState(() {
                                selectedStates = List.filled(
                                  provider.stateList.length,
                                  false,
                                );
                              });
                            },
                            child: Text(
                              'Reset',
                              style: GoogleFonts.montserrat(
                                color: const Color(0xFFFF6B1B),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Update selected state
                              selectedState = '';
                              for (
                                int i = 0;
                                i < provider.stateList.length;
                                i++
                              ) {
                                if (selectedStates[i]) {
                                  selectedState =
                                      provider.stateList[i].text ?? '';
                                  break;
                                }
                              }
                              setState(() {});
                              _applyFilter();
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B1B),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'Apply',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Cash Pendency',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Consumer<CashPendencyProvider>(
        builder: (context, provider, child) {
          String getSelectedStateText() {
            if (selectedState.isNotEmpty) {
              return selectedState;
            }
            final selected = <String>[];
            for (
              int i = 0;
              i < provider.stateList.length && i < selectedStates.length;
              i++
            ) {
              if (selectedStates[i]) {
                selected.add(provider.stateList[i].text ?? '');
              }
            }
            return selected.isEmpty ? 'Select State' : selected.join(', ');
          }

          if (provider.isLaoding) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B1B)),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _showStateBottomSheet,
                        child: Row(
                          children: [
                            Text(
                              getSelectedStateText(),
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: getSelectedStateText() == 'Select State'
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: _showFilterBottomSheet,
                      child: Row(
                        children: [
                          Text(
                            'Filter',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          SvgPicture.asset('assets/filter.svg'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Table Calendar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Custom header with Previous/Next buttons
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _focusedDay = _focusedDay.subtract(
                                  const Duration(days: 1),
                                );
                                selectedDate =
                                    '${_focusedDay.year}-${_focusedDay.month.toString().padLeft(2, '0')}-${_focusedDay.day.toString().padLeft(2, '0')}';
                              });
                              _applyFilter();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFFF6B1B),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.chevron_left,
                                    color: Color(0xFFFF6B1B),
                                    size: 16,
                                  ),
                                  Text(
                                    'Previous',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      color: const Color(0xFFFF6B1B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            selectedDate,
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _focusedDay = _focusedDay.add(
                                  const Duration(days: 1),
                                );
                                selectedDate =
                                    '${_focusedDay.year}-${_focusedDay.month.toString().padLeft(2, '0')}-${_focusedDay.day.toString().padLeft(2, '0')}';
                              });
                              _applyFilter();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFFF6B1B),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Next',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      color: const Color(0xFFFF6B1B),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFFFF6B1B),
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Tab Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _selectedTabIndex = 0;
                                  _applyFilter();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    'Branch Wise',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: _selectedTabIndex == 0
                                          ? const Color(0xFFFF6B1B)
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _selectedTabIndex = 1;
                                  _applyFilter();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    'Branch Type Wise',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: _selectedTabIndex == 1
                                          ? const Color(0xFFFF6B1B)
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 2,
                            width: _selectedTabIndex == 0 ? 80 : 120,
                            color: const Color(0xFFFF6B1B),
                            margin: EdgeInsets.only(
                              left: _selectedTabIndex == 0 ? 16 : 140,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              if (selectedCompany.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFFF6B1B)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Company: $selectedCompany',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: const Color(0xFFFF6B1B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCompany = '';
                            selectedCompanies = List.filled(
                              cashPendencyProvider!.companyList.length,
                              false,
                            );
                          });
                          _applyFilter();
                        },
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Color(0xFFFF6B1B),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              Expanded(
                child: provider.cashPendencyList.isEmpty
                    ? Center(
                        child: Text(
                          'No data available',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0xFFFFD6BF), Color(0xFFFFFFFF)],
                                stops: [0.0, 0.12],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                border: TableBorder.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                                columnSpacing: 15,
                                headingRowHeight: 50,
                                columns: [
                                  DataColumn(
                                    label: Text(
                                      'Report Title',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xfff808080),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Total Cash',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xfff808080),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Prev Total Cash',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xfff808080),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Change %',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xfff808080),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Report ID',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xfff808080),
                                      ),
                                    ),
                                  ),
                                ],
                                rows: provider.cashPendencyList
                                    .map(
                                      (pendency) => DataRow(
                                        cells: [
                                          DataCell(
                                            Text(
                                              pendency.reportTitle ?? 'N/A',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              pendency.totalCash!.toString(),
                                              style: GoogleFonts.montserrat(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              pendency.prevTotalCash.toString(),
                                              style: GoogleFonts.montserrat(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              '${pendency.changeInPer ?? 0}%',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              pendency.reportId!.toString(),
                                              style: GoogleFonts.montserrat(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
